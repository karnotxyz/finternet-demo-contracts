use starknet::ContractAddress;
pub use crate::types::{Status, Registration};

#[starknet::interface]
pub trait ITokenManagerRegistry<TContractState> {
    fn is_registered(self: @TContractState, entity: ContractAddress) -> bool;
    fn register(ref self: TContractState, entity: ContractAddress, document_hash: felt252);
    fn get_registration_status(self: @TContractState, entity: ContractAddress) -> Registration;
    fn approve_registration(ref self: TContractState, entity: ContractAddress);
}
