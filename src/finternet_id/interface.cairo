use starknet::ContractAddress;

#[starknet::interface]
pub trait IFinternetId<TContractState> {
    fn get_id(self: @TContractState, user: ContractAddress) -> ByteArray;
    fn register(ref self: TContractState, user: ContractAddress, finternet_id: ByteArray);
}
