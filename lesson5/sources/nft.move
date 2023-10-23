module lesson5::discount_coupon {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::clock::{Self, Clock};
    use sui::coin::Coin;
    use sui::sui::SUI;

    const TIME_EXPIRED: u64 = 0;

    struct DiscountCoupon has key, store {
        id: UID,
        owner: address,
        discount: u8,
        expiration: u64,
    }

    public fun owner(coupon: &DiscountCoupon): address {
        coupon.owner
    }

    public fun discount(coupon: &DiscountCoupon): u8 {
        coupon.discount
    }

    public entry fun mint_and_topup(
        coin: Coin<SUI>,
        discount: u8,
        expiration: u64,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let coupon = DiscountCoupon {
            id: object::new(ctx),
            owner: tx_context::sender(ctx),
            discount,
            expiration,
        };

        transfer::transfer(coupon, recipient);
        transfer::public_transfer(coin, recipient);
    }

    public entry fun transfer_coupon(coupon: DiscountCoupon, recipient: address) {
        transfer::public_transfer(coupon, recipient);
    }

    public fun burn(coupon: DiscountCoupon) {
        let DiscountCoupon {id, owner: _, discount: _, expiration: _} = coupon;

        object::delete(id);
    }

    public entry fun scan(coupon: DiscountCoupon, clock: &Clock) {
        assert!(coupon.expiration >= clock::timestamp_ms(clock), TIME_EXPIRED);
        burn(coupon);
    }
}
