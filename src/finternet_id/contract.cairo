#[starknet::contract]
pub mod FinternetId {
    use starknet::ContractAddress;

    use starknet::storage::Map;
    use crate::finternet_id::interface::IFinternetId;

    #[storage]
    struct Storage {
        id: Map<ContractAddress, felt252>,
        claimed_ids: Map<felt252, bool>,
    }

    impl IFinternetIdImpl of IFinternetId<ContractState> {
        fn get_id(self: @ContractState, user: ContractAddress) -> felt252 {
            self.id.read(user)
        }

        fn register(ref self: ContractState, user: ContractAddress, finternet_id: felt252) {
            assert!(self.claimed_ids.read(finternet_id) == false, "ID already claimed");
            self.claimed_ids.write(finternet_id, true);
        }
    }
}
