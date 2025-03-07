#[starknet::contract]
pub mod FinternetId {
    use starknet::ContractAddress;

    use starknet::storage::Map;
    use crate::finternet_id::interface::IFinternetId;

    #[storage]
    struct Storage {
        id: Map<ContractAddress, felt252>,
        id_to_user: Map<felt252, ContractAddress>,
        claimed_ids: Map<felt252, bool>,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {}

    #[abi(embed_v0)]
    impl IFinternetIdImpl of IFinternetId<ContractState> {
        fn get_id(self: @ContractState, user: ContractAddress) -> felt252 {
            self.id.read(user)
        }

        fn register(ref self: ContractState, user: ContractAddress, finternet_id: felt252) {
            assert!(self.claimed_ids.read(finternet_id) == false, "ID already claimed");
            self.claimed_ids.write(finternet_id, true);
            self.id.write(user, finternet_id);
            self.id_to_user.write(finternet_id, user);
        }

        fn get_user_by_id(self: @ContractState, finternet_id: felt252) -> ContractAddress {
            self.id_to_user.read(finternet_id)
        }
    }
}
