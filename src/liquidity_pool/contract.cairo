#[starknet::contract]
pub mod LiquidityPool {
    use starknet::{ContractAddress, get_caller_address, get_contract_address};
    use starknet::storage::Map;

    use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use crate::kyc_registry::interface::{
        IKycRegistryDispatcher, IKycRegistryDispatcherTrait, Status,
    };

    use crate::liquidity_pool::interface::ILiquidityPool;

    #[storage]
    struct Storage {
        id: Map<ContractAddress, ByteArray>,
        exchange_rate: u128, // (token1 * 1000_000 / token0)
        kyc_registry: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, kyc_registry: ContractAddress) {
        self.kyc_registry.write(kyc_registry);
    }

    #[abi(embed_v0)]
    impl ILiquidityPoolImpl of ILiquidityPool<ContractState> {
        fn add_liquidity(
            ref self: ContractState,
            token1: ContractAddress,
            token2: ContractAddress,
            token1_amount: u128,
            token2_amount: u128,
        ) {
            let caller = get_caller_address();
            self.check_kyc(caller);
            let dispatcher_token1 = IERC20Dispatcher { contract_address: token1 };
            let dispatcher_token2 = IERC20Dispatcher { contract_address: token2 };

            dispatcher_token1.transfer_from(caller, get_contract_address(), token1_amount.into());
            dispatcher_token2.transfer_from(caller, get_contract_address(), token2_amount.into());
        }

        fn perform_forex(
            ref self: ContractState,
            in_token: ContractAddress,
            out_token: ContractAddress,
            in_amount: u128,
            recipient: ContractAddress,
        ) {
            let caller = get_caller_address();
            self.check_kyc(caller);
            self.check_kyc(recipient);

            let dispatcher_in = IERC20Dispatcher { contract_address: in_token };
            let dispatcher_out = IERC20Dispatcher { contract_address: out_token };

            dispatcher_in.transfer_from(caller, get_contract_address(), in_amount.into());
            if (in_token < out_token) {
                let out_amount = (in_amount * self.exchange_rate.read()) / 1000000;
                dispatcher_out.transfer(recipient, out_amount.into());
            } else {
                let out_amount = (in_amount * 1000000) / self.exchange_rate.read();
                dispatcher_out.transfer(recipient, out_amount.into());
            }
        }

        fn get_exchange_rate(self: @ContractState) -> u128 {
            self.exchange_rate.read()
        }
    }

    #[generate_trait]
    impl ILiquidityPoolInternalImpl of ILiquidityPoolInternal {
        fn set_exchange_rate(ref self: ContractState, exchange_rate: u128) {
            self.exchange_rate.write(exchange_rate);
        }

        fn check_kyc(ref self: ContractState, user: ContractAddress) {
            let kyc_registry = IKycRegistryDispatcher {
                contract_address: self.kyc_registry.read(),
            };
            let registration = kyc_registry.get_registration_status(user);
            assert(registration.status == Status::Active, 'KYC not approved');
        }
    }
}
