#[starknet::contract]
pub mod TokenManager {
    use OwnableComponent::InternalTrait;
    use starknet::ContractAddress;
    use starknet::storage::{Map};
    use crate::token_manager_registry::interface::{ITokenManagerRegistry, Status, Registration};

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

        fn approve_registration(ref self: ContractState, entity: ContractAddress) {
            self.ownable.assert_only_owner();
            let registration = self.registration.read(entity);
            let updated_registration = Registration { status: Status::Active, ..registration };
            self.registration.write(entity, updated_registration);
        }
    }
}
