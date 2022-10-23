
//admin address was initialized in the move.toml
address admin {

module degenomicstoken {

    //importing modules from libries
    use aptos_framework::coin;
    use std::signer;
    //std libary allows strings in move
    use std::string;

    struct DEGEN{}
//struch defining coin capabilities
    struct CoinCapabilities<phantom DEGEN> has key {
        //basic functions of the coin module
        mint_capability: coin::MintCapability<DEGEN>,
        burn_capability: coin::BurnCapability<DEGEN>,
        freeze_capability: coin::FreezeCapability<DEGEN>,
    }
//defining errors

//defining error for non admin operations
    const Error_not_admin: u64 = 0;
//deffining errors for no capabilities
    const Error_no_capabilities: u64 = 1;
    //defining errors for capabilities if they exist already
    const Error_for_capabilities: u64 = 2;


//function to initialize degenomics token on the aptos blockchain

    public entry fun inititializeDEGEN(account: &signer) {
        let (burn_capability, freeze_capability, mint_capability) = coin::initialize<DEGEN>(
            account,
            string::utf8(b"Degenomics token"),
            string::utf8(b"DEGEN"),
            18,
            true,
        );

        assert!(signer::address_of(account) == @admin, Error_not_admin);
        assert!(!exists<CoinCapabilities<DEGEN>>(@admin), Error_for_capabilities);

        move_to<CoinCapabilities<DEGEN>>(account, CoinCapabilities<DEGEN>{mint_capability, burn_capability, freeze_capability});
    }

    public entry fun mint<DEGEN>(account: &signer, user: address, amount: u64) acquires CoinCapabilities {
        let account_address = signer::address_of(account);
        assert!(account_address == @admin, Error_not_admin);
        assert!(exists<CoinCapabilities<DEGEN>>(account_address), Error_no_capabilities);
        let mint_capability = &borrow_global<CoinCapabilities<DEGEN>>(account_address).mint_capability;
        let coins = coin::mint<DEGEN>(amount, mint_capability);
        coin::deposit(user, coins)
    }

    public entry fun burn<DEGEN>(coins: coin::Coin<DEGEN>) acquires CoinCapabilities {
        let burn_capability = &borrow_global<CoinCapabilities<DEGEN>>(@admin).burn_capability;
        coin::burn<DEGEN>(coins, burn_capability);
    }
}
}