module lesson5::FT_TOKEN {
    use std::option::{Self, Option};
    use sui::url::{Self, Url};
    use sui::coin;
    use sui::coin::{TreasuryCap, Coin, CoinMetadata};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::event;
    use std::string::{String, to_ascii, utf8};
    use std::ascii::{String as AString};

    struct FT_TOKEN has drop { }

    // event
    struct TokenMinted has copy, drop {
        success: bool,
        recipient: address,
        amount: u64
    }

    struct TokenTransferred has copy, drop {
        success: bool,
        recipient: address
    }

    struct TokenBurned has copy, drop {
        success: bool,
    }

    struct CoinSplitted has copy, drop {
        amount: u64
    }

    struct MetadataUpdated has copy, drop {
        success: bool,
        type: String,
        data: AString
    }

    fun init(witness: FT_TOKEN, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency<FT_TOKEN>(
            witness,
            2,
            b"GANZZI$",
            b"GANZZI$",
            b"TOKEN FOR EVERYONE$",
            option::some(url::new_unsafe_from_bytes(b"http://abc")),
            ctx
        );

        transfer::public_transfer(metadata, tx_context::sender(ctx));
        transfer::public_share_object(treasury_cap);
    }

    public entry fun mint(_: &CoinMetadata<FT_TOKEN>, treasury_cap: &mut TreasuryCap<FT_TOKEN>, amount: u64, recipient: address, ctx: &mut TxContext) {
        coin::mint_and_transfer(treasury_cap, amount, recipient, ctx);
        event::emit(TokenMinted {
            success: true,
            recipient,
            amount
        })
    }

    public entry fun burn_token(treasury_cap: &mut TreasuryCap<FT_TOKEN>, coin: Coin<FT_TOKEN>) {
        coin::burn(treasury_cap, coin);
        event::emit(TokenBurned {
            success: true
        })
    }

    public entry fun transfer_token(coin: Coin<FT_TOKEN>, recipient: address) {
        transfer::public_transfer(coin, recipient);
        event::emit(TokenTransferred {
            success: true,
            recipient
        })
    }

    public entry fun split_token(coin: &mut Coin<FT_TOKEN>, amount: u64, ctx: &mut TxContext) {
        let new_coin = coin::split(coin, amount, ctx);
        event::emit(CoinSplitted {
            amount
        });
        transfer::public_transfer(new_coin, tx_context::sender(ctx));
    }

    public entry fun update_name(
        treasury_cap: &TreasuryCap<FT_TOKEN>,
        metadata: &mut CoinMetadata<FT_TOKEN>,
        name: String
    ) {
        coin::update_name(treasury_cap, metadata, name);
        event::emit(MetadataUpdated {
            success: true,
            type: utf8(b"name"),
            data: to_ascii(name)
        });
    }

    public entry fun update_description(
        treasury_cap: &TreasuryCap<FT_TOKEN>,
        metadata: &mut CoinMetadata<FT_TOKEN>,
        description: String
    ) {
        coin::update_description(treasury_cap, metadata, description);
        event::emit(MetadataUpdated {
            success: true,
            type: utf8(b"description"),
            data: to_ascii(description)
        });
    }
    public entry fun update_symbol(
        treasury_cap: &TreasuryCap<FT_TOKEN>,
        metadata: &mut CoinMetadata<FT_TOKEN>,
        symbol: AString
    ) {
        coin::update_symbol(treasury_cap, metadata, symbol);
        event::emit(MetadataUpdated {
            success: true,
            type: utf8(b"symbol"),
            data: symbol
        });
    }
    public entry fun update_icon_url(
        treasury_cap: &TreasuryCap<FT_TOKEN>,
        metadata: &mut CoinMetadata<FT_TOKEN>,
        icon_url: AString
    ) {
        coin::update_icon_url(treasury_cap, metadata, icon_url);
        event::emit(MetadataUpdated {
            success: true,
            type: utf8(b"icon_url"),
            data: icon_url
        });
    }

    public entry fun get_token_name(metadata: &coin::CoinMetadata<FT_TOKEN>): String {
        coin::get_name(metadata)
    }
    public entry fun get_token_description(metadata: &coin::CoinMetadata<FT_TOKEN>): String {
        coin::get_description(metadata)
    }
    public entry fun get_token_symbol(metadata: &coin::CoinMetadata<FT_TOKEN>): AString {
        coin::get_symbol(metadata)
    }
    public entry fun get_token_icon_url(metadata: &coin::CoinMetadata<FT_TOKEN>): Option<Url> {
        coin::get_icon_url(metadata)
    }
}