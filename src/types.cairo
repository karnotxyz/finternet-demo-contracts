#[derive(Serde, starknet::Store, PartialEq, Drop, Debug, Clone)]
pub enum Status {
    #[default]
    Unknown,
    UnderReview,
    Active,
    InActive,
}


#[derive(Serde, starknet::Store, Drop, Debug, Clone)]
pub struct Registration {
    pub status: Status,
    pub document_hash: felt252,
}
