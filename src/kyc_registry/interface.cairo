use starknet::ContractAddress;
pub use crate::types::{Status, Registration};

#[starknet::interface]
pub trait IKycRegistry<TContractState> {
    fn is_registered(self: @TContractState, user: ContractAddress) -> bool;
    fn register(ref self: TContractState, user: ContractAddress, document_hash: felt252);
    fn get_registration_status(self: @TContractState, user: ContractAddress) -> Registration;
    fn approve_registration(ref self: TContractState, user: ContractAddress);
}
