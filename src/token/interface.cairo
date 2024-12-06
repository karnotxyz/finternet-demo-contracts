use starknet::ContractAddress;

#[starknet::interface]
pub trait IMintableERC20<TContractState> {
    fn mint(ref self: TContractState, recipient: ContractAddress, amount: u256);
}
