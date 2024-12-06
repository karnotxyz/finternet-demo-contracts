#[starknet::contract]
pub mod TokenManager {
    use OwnableComponent::InternalTrait;
    use starknet::{ContractAddress, get_caller_address};
    use starknet::storage::{Map};
    use crate::token_manager_registry::interface::{
        ITokenManagerGovernor, ITokenManagerRegistry, Status, Registration,
    };
    use crate::token::interface::{IMintableERC20Dispatcher, IMintableERC20DispatcherTrait};
    use crate::kyc_registry::interface::{IKycRegistryDispatcher, IKycRegistryDispatcherTrait};

    use openzeppelin::access::ownable::OwnableComponent;

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl OwnableTwoStepImpl = OwnableComponent::OwnableTwoStepImpl<ContractState>;
    impl InternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    pub struct Storage {
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        registration: Map<ContractAddress, Registration>,
        whitelisted_currencies: Map<ContractAddress, bool>,
        kyc_registry: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress, kyc_registry: ContractAddress) {
        self.ownable.initializer(owner);
        self.kyc_registry.write(kyc_registry);
    }

    #[abi(embed_v0)]
    impl ITokenManagerRegistryImpl of ITokenManagerRegistry<ContractState> {
        fn is_registered(self: @ContractState, entity: ContractAddress) -> bool {
            self.registration.read(entity).status == Status::Active
        }

        fn register(ref self: ContractState, entity: ContractAddress, document_hash: felt252) {
            self
                .registration
                .write(entity, Registration { status: Status::Unknown, document_hash });
        }

        fn get_registration_status(self: @ContractState, entity: ContractAddress) -> Registration {
            self.registration.read(entity)
        }


        fn tokenize(
            ref self: ContractState, currency: ContractAddress, user: ContractAddress, amount: u128,
        ) {
            self.assert_only_registered();
            assert(self.whitelisted_currencies.read(currency) == true, 'Not whitelisted');

            self.assert_only_kyc_approved(user);
            let dispatcher = IMintableERC20Dispatcher { contract_address: currency };
            dispatcher.mint(user, amount.into());
        }
    }

    #[abi(embed_v0)]
    impl ITokenManagerGovernorImpl of ITokenManagerGovernor<ContractState> {
        fn approve_registration(ref self: ContractState, entity: ContractAddress) {
            self.ownable.assert_only_owner();
            let registration = self.registration.read(entity);
            let updated_registration = Registration { status: Status::Active, ..registration };
            self.registration.write(entity, updated_registration);
        }

        fn whitelist_currency(ref self: ContractState, currency: ContractAddress) {
            self.ownable.assert_only_owner();
            self.whitelisted_currencies.write(currency, true);
        }
    }

    #[generate_trait]
    impl TokenManagerInternalImpl of TokenManagerInternalTrait {
        fn assert_only_registered(self: @ContractState) {
            let caller = get_caller_address();
            assert(self.is_registered(caller), 'Not registered');
        }

        fn assert_only_kyc_approved(self: @ContractState, user: ContractAddress) {
            let kyc_registry = IKycRegistryDispatcher {
                contract_address: self.kyc_registry.read(),
            };
            let registration = kyc_registry.get_registration_status(user);
            assert(registration.status == Status::Active, 'KYC not approved');
        }
    }
}
