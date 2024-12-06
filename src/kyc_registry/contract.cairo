#[starknet::contract]
pub mod KycRegistry {
    use starknet::ContractAddress;
    use crate::types::{Status, Registration};

    use starknet::storage::Map;
    use crate::kyc_registry::interface::IKycRegistry;

    use openzeppelin::access::ownable::OwnableComponent;

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);


    #[abi(embed_v0)]
    impl OwnableTwoStepImpl = OwnableComponent::OwnableTwoStepImpl<ContractState>;
    impl InternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        kyc: Map<ContractAddress, Registration>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event,
    }


    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.ownable.initializer(owner);
    }

    #[abi(embed_v0)]
    impl IKycRegistryImpl of IKycRegistry<ContractState> {
        fn is_registered(self: @ContractState, user: ContractAddress) -> bool {
            self.kyc.read(user).status == Status::Active
        }

        fn register(ref self: ContractState, user: ContractAddress, document_hash: felt252) {
            self.kyc.write(user, Registration { status: Status::Unknown, document_hash });
        }

        fn get_registration_status(self: @ContractState, user: ContractAddress) -> Registration {
            self.kyc.read(user)
        }

        fn approve_registration(ref self: ContractState, user: ContractAddress) {
            self.ownable.assert_only_owner();
            let registration = self.kyc.read(user);
            let update = Registration { status: Status::Active, ..registration };
            self.kyc.write(user, update);
        }
    }
}
