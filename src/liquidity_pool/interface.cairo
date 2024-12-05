use starknet::ContractAddress;

#[starknet::interface]
pub trait ILiquidityPool<TContractState> {
    fn add_liquidity(ref self: TContractState, token1: ContractAddress, token2: ContractAddress);
    fn swap(
        ref self: TContractState,
        in_token: ContractAddress,
        out_token: ContractAddress,
        in_amount: felt252,
    );
}
