#[starknet::contract]
pub mod FinternetId {
    use starknet::ContractAddress;

    use starknet::storage::Map;
    use crate::finternet_id::interface::IFinternetId;

    #[storage]
    struct Storage {
        id: Map<ContractAddress, felt252>,
        total_ids: u128,
    }

    impl IFinternetIdImpl of IFinternetId<ContractState> {
        fn get_id(self: @ContractState, user: ContractAddress) -> felt252 {
            self.id.read(user)
        }

        fn register(ref self: ContractState, user: ContractAddress, finternet_id: felt252) {
            self.total_ids.write(self.total_ids.read() + 1);
            self.id.write(user, finternet_id);
        }
    }
}
