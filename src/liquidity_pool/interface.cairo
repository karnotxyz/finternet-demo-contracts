use starknet::ContractAddress;

#[starknet::interface]
pub trait ILiquidityPool<TContractState> {
    fn add_liquidity(
        ref self: TContractState,
        token1: ContractAddress,
        token2: ContractAddress,
        token1_amount: u128,
        token2_amount: u128,
    );
    fn perform_forex(
        ref self: TContractState,
        in_token: ContractAddress,
        out_token: ContractAddress,
        in_amount: u128,
        recipient: ContractAddress,
    );
    fn get_exchange_rate(self: @TContractState) -> u128;
    fn set_exchange_rate(ref self: TContractState, exchange_rate: u128);
}
