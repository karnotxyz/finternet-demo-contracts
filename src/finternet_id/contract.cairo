#[starknet::contract]
pub mod FinternetId {
    use starknet::ContractAddress;

    use starknet::storage::Map;
    use crate::finternet_id::interface::IFinternetId;

    #[storage]
    struct Storage {
        id: Map<ContractAddress, ByteArray>,
    }

    impl IFinternetIdImpl of IFinternetId<ContractState> {
        fn get_id(self: @ContractState, user: ContractAddress) -> ByteArray {
            self.id.read(user)
        }

        fn register(ref self: ContractState, user: ContractAddress, finternet_id: ByteArray) {
            self.id.write(user, finternet_id);
        }
    }
}
