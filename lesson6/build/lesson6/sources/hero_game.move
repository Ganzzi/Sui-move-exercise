module lesson6::hero_game {
    use sui::object::{Self, UID, ID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::sui::SUI;
    use std::string::{Self, String};
    use sui::coin::{Self, Coin};
    use std::option::{Self, Option};

    const DEPOSIT_TOO_LOW: u64 = 0;
    const HERO_DIED: u64 = 1;

    struct Hero has key, store {
        id: UID,
        name: String,
        hp: u64,
        experience: u64,
        armor: Option<Armor>,
        sword: Option<Sword>,
        game_id: ID
    }

    struct Sword has store, key {
        id: UID,
        attack: u64,
        game_id: ID,
    }

    struct Armor has store, key {
        id: UID,
        defense: u64,
        game_id: ID,
    }

    struct Monster has store, key {
        id: UID,
        name: String,
        hp: u64,
        attack: u64,
        game_id: ID
    }

    struct Game has key, store {
        id: UID,
        admin: address
    }

    struct GameAdmin has key {
        id: UID,
        game_id: ID,
        heros: u64,
        monsters: u64
    }

    fun init(ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let id = object::new(ctx);
        let game_id = object::uid_to_inner(&id);

        let game = Game {
            id,
            admin: sender
        };

        let game_admin = GameAdmin {
            id: object::new(ctx),
            game_id,
            monsters: 0,
            heros: 0
        };

        transfer::freeze_object(game);
        transfer::transfer(game_admin, sender);
    }

    public fun create_hero(game: &Game, name: String, sword: Sword, armor: Armor, ctx: &mut TxContext): Hero {
        Hero {
            id: object::new(ctx),
            name, 
            hp: 100,
            experience: 0,
            sword: option::some(sword),
            armor: option::some(armor),
            game_id: game_id(game)
        }
    }
    public fun create_sword(game: &Game, payment: Coin<SUI>, ctx: &mut TxContext): Sword {
        let value = coin::value(&payment);
        assert!(value >= 10, DEPOSIT_TOO_LOW);

        transfer::public_transfer(payment, game.admin);

        Sword {
            id: object::new(ctx),
            attack: value,
            game_id: game_id(game)
        }
    }
    public fun create_armor(game: &Game, payment: Coin<SUI>, ctx: &mut TxContext): Armor {
        let value = coin::value(&payment);
        assert!(value >= 10, DEPOSIT_TOO_LOW);

        transfer::public_transfer(payment, game.admin);

        Armor {
            id: object::new(ctx),
            defense: value,
            game_id: game_id(game)
        }
    }

    public fun create_monter(
        game: &Game,
        admin: &mut GameAdmin,
        name: String,
        hp: u64,
        attack: u64,
        ctx: &mut TxContext,
    ): Monster {
        admin.monsters = admin.monsters + 1;

        Monster {
            id: object::new(ctx),
            name,
            hp,
            attack,
            game_id: game_id(game),
        }
    }

    fun level_up_sword(sword: &mut Sword, amount: u64) {
        sword.attack + amount;
    }
    fun level_up_armor(armor: &mut Armor, amount: u64) {
        armor.defense + amount;
    }
    fun level_up_hero(hero: &mut Hero, amount: u64) {
        hero.experience + amount;
    }

    public fun game_id(game: &Game): ID {
        object::id(game)
    }

    public entry fun attack_monter(hero: &mut Hero, monster: Monster) {
        let Monster {id: m_id, hp: m_hp, attack: monster_attack, name: _, game_id: _} = monster;

        let hero_attack = hero_attack(hero);
        let hero_defense = hero_defense(hero);

        let hero_hp = hero.hp;
        let _monster_hp = m_hp;

        while (_monster_hp > hero.hp) {
            if(hero_attack >= _monster_hp){
                _monster_hp = 0;
                break
            };
            _monster_hp - hero_attack;

            assert!((monster_attack - hero_defense) > hero_hp, HERO_DIED);
            hero_hp - (monster_attack - hero_defense);

        };

        object::delete(m_id);

        hero.hp = hero_hp;
        level_up_hero(hero, 2);
        if (option::is_some(&hero.sword)) {
            level_up_sword(option::borrow_mut(&mut hero.sword), 2);
        };
        if (option::is_some(&hero.armor)) {
            level_up_armor(option::borrow_mut(&mut hero.armor), 2);
        };
    }

    public fun hero_attack(hero: &Hero): u64 {
        let attack = if (option::is_some(&hero.sword)) {
            sword_strength(option::borrow(&hero.sword))
        } else {
            0
        };
        attack
    }

    public fun hero_defense(hero: &Hero): u64 {
        let defense = if (option::is_some(&hero.armor)) {
            armor_strength(option::borrow(&hero.armor))
        } else {
            0
        };
        defense
    }

    public fun sword_strength(sword: &Sword): u64{
        sword.attack
    }

    public fun armor_strength(armor: &Armor): u64{
        armor.defense
    }
}
