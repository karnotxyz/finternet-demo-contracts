use starknet::ContractAddress;
pub use crate::types::{Status, Registration};

#[starknet::interface]
pub trait ITokenManagerRegistry<TContractState> {
    fn is_registered(self: @TContractState, entity: ContractAddress) -> bool;
    fn register(ref self: TContractState, entity: ContractAddress, document_hash: felt252);
    fn get_registration_status(self: @TContractState, entity: ContractAddress) -> Registration;

    fn tokenize(
        ref self: TContractState, currency: ContractAddress, user: ContractAddress, amount: u128,
    );
}


#[starknet::interface]
pub trait ITokenManagerGovernor<TContractState> {
    fn approve_registration(ref self: TContractState, entity: ContractAddress);
    fn whitelist_currency(ref self: TContractState, currency: ContractAddress);
}
