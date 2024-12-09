use starknet::ContractAddress;

#[starknet::interface]
pub trait IFinternetId<TContractState> {
    fn get_id(self: @TContractState, user: ContractAddress) -> felt252;
    fn register(ref self: TContractState, user: ContractAddress, finternet_id: felt252);
    fn get_user_by_id(self: @TContractState, finternet_id: felt252) -> ContractAddress;
}
