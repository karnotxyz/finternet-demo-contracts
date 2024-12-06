#[starknet::contract]
pub mod LiquidityPool {
    use starknet::{ContractAddress, get_caller_address, get_contract_address};
    use starknet::storage::Map;

    use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};

    use crate::liquidity_pool::interface::ILiquidityPool;

    #[storage]
    struct Storage {
        id: Map<ContractAddress, ByteArray>,
        exchange_rate: u128 // (token1 * 1000_000 / token0)
    }

    impl ILiquidityPoolImpl of ILiquidityPool<ContractState> {
        fn add_liquidity(
            ref self: ContractState, token1: ContractAddress, token2: ContractAddress,
        ) {}

        fn swap(
            ref self: ContractState,
            in_token: ContractAddress,
            out_token: ContractAddress,
            in_amount: u128,
        ) {
            let caller = get_caller_address();
            let dispatcher_in = IERC20Dispatcher { contract_address: in_token };
            let dispatcher_out = IERC20Dispatcher { contract_address: out_token };

            dispatcher_in.transfer_from(caller, get_contract_address(), in_amount.into());
            if (in_token < out_token) {
                let out_amount = (in_amount * self.exchange_rate.read()) / 1000000;
                dispatcher_out.transfer(caller, out_amount.into());
            } else {
                let out_amount = (in_amount * 1000000) / self.exchange_rate.read();
                dispatcher_out.transfer(caller, out_amount.into());
            }
        }
    }
}
