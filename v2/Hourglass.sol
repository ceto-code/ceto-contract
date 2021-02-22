pragma solidity 0.5.15;

/*
:'######::'########:'########::'#######::
'##... ##: ##.....::... ##..::'##.... ##:
 ##:::..:: ##:::::::::: ##:::: ##:::: ##:
 ##::::::: ######:::::: ##:::: ##:::: ##:
 ##::::::: ##...::::::: ##:::: ##:::: ##:
 ##::: ##: ##:::::::::: ##:::: ##:::: ##:
. ######:: ########:::: ##::::. #######::
:......:::........:::::..::::::.......:::

Creator: 773d62b24a9d49e1f990b22e3ef1a9903f44ee809a12d73e660c66c1772c47dd

CETO v2: v1 faced the bug https://github.com/ceto-code/ceto-contract/blob/main/BugReport.md
*/

contract Hourglass {
    /*=================================
    =            MODIFIERS            =
    =================================*/
    // only people with tokens
    modifier onlyBagholders() {
        require(myTokens() > 0);
        _;
    }

    // administrators can:
    // -> change the name of the contract
    // -> change the name of the token
    // -> change the PoS difficulty (How many tokens it costs to hold a masternode, in case it gets crazy high later)
    // they CANNOT:
    // -> take funds
    // -> disable withdrawals
    // -> kill the contract
    // -> change the price of tokens
    modifier onlyAdministrator() {
        address _customerAddress = msg.sender;
        require(administrators[_customerAddress], "This address is not an admin");
        _;
    }

    bool public adminCanChangeState = true;

    modifier onlyAdministratorIntialStage() {
        address _customerAddress = msg.sender;
        require(administrators[_customerAddress], "This address is not an admin");
        require(adminCanChangeState, "Admin can't change the contract state now");
        _;
    }

    /*==============================
    =            EVENTS            =
    ==============================*/
    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingTron,
        uint256 tokensMinted,
        address indexed referredBy
    );

    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 tronEarned
    );

    event onReinvestment(
        address indexed customerAddress,
        uint256 tronReinvested,
        uint256 tokensMinted
    );

    event onWithdraw(address indexed customerAddress, uint256 tronWithdrawn);

    // TRC20
    event Transfer(address indexed from, address indexed to, uint256 tokens);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    // When a customer sets up AutoReinvestment
    event onAutoReinvestmentEntry(
        address indexed customerAddress,
        uint256 nextExecutionTime,
        uint256 rewardPerInvocation,
        uint24 period,
        uint256 minimumDividendValue
    );

    // When a customer stops AutoReinvestment
    event onAutoReinvestmentStop(address indexed customerAddress);

    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/
    string public name = "Crystal Elephant Token";
    string public symbol = "CETO";
    uint8 public constant decimals = 6;
    uint8 internal constant dividendFee_ = 10;
    uint256 internal constant tokenPriceInitial_ = 1000; // unit: sun
    uint256 internal constant tokenPriceIncremental_ = 100; // unit: sun
    uint256 internal constant magnitude = 2**64;

    // requirement for earning a referral bonus (defaults at 100 tokens)
    uint256 public stakingRequirement = 100e6;

    /*================================
    =            DATASETS            =
    ================================*/
    // amount of tokens for each address (scaled number)
    mapping(address => uint256) internal tokenBalanceLedger_;

    // amount of tokens bought with their buy timestamp for each address
    struct TimestampedBalance {
        uint256 value;
        uint256 timestamp;
        uint256 valueSold;
    }

    mapping(address => TimestampedBalance[])
        internal tokenTimestampedBalanceLedger_;

    // The start and end index of the unsold timestamped transactions list
    struct Cursor {
        uint256 start;
        uint256 end;
    }

    mapping(address => Cursor) internal tokenTimestampedBalanceCursor;

    // mappings to and from referral address
    mapping(address => bytes32) public referralMapping;
    mapping(bytes32 => address) public referralReverseMapping;

    // The current referral balance
    mapping(address => uint256) public referralBalance_;
    // All time referrals earnings
    mapping(address => uint256) public referralIncome_;

    mapping(address => int256) internal payoutsTo_;
    uint256 internal tokenSupply_ = 0;
    uint256 internal profitPerShare_;

    // administrator list (see above on what they can do)
    mapping(address => bool) public administrators;

    /*=======================================
    =            PUBLIC FUNCTIONS            =
    =======================================*/
    /*
     * -- APPLICATION ENTRY POINTS --
     */
    constructor() public {
        address owner = msg.sender;
        administrators[owner] = true;

        // Set the old state of the v1 contract(TLqB1kuXuKeKzeGkvrZjpLA6Kz6pN2LHj5)
        referralBalance_[0x45De5dFb0E13d6933Afed37870BE6eaf87b4cDEe] = 53333333;
        referralIncome_[0x45De5dFb0E13d6933Afed37870BE6eaf87b4cDEe] = 54999999;

        tokenSupply_ = 151524101126;
        profitPerShare_ = 24809137937556660190;

        tokenBalanceLedger_[0x5716d088a6E3f30FdC8c08eA5c519C103D2BBC24] = 57883882539;
        tokenBalanceLedger_[0x45De5dFb0E13d6933Afed37870BE6eaf87b4cDEe] = 602987747;
        tokenBalanceLedger_[0x977C7C7356bB046c66d42977da76FdD919B13968] = 5015050398;
        tokenBalanceLedger_[0xfafAa13890452fA444959798302ff8A2d207915d] = 11276741563;
        tokenBalanceLedger_[0xc5f6Bb13B0C2B293391195D04945c6c85708C61a] = 642713425;
        tokenBalanceLedger_[0xc0c6B3d8F93C348474Aee5328d7aB9BECB7dAeAc] = 8953079794;
        tokenBalanceLedger_[0x0Fc480eB1fC590a37647275529B875417C1e4f06] = 4444456768;
        tokenBalanceLedger_[0xdafD17E58f48D462BC7F271A3eee7486B419A632] = 6114951651;
        tokenBalanceLedger_[0x0Cfc783943553a0c91A68d46f9c971128D7d8Aee] = 241572748;
        tokenBalanceLedger_[0x47f06D6269B2fca8238326C26Ef8D5663A2DEde8] = 950502624;
        tokenBalanceLedger_[0x7C6E870fBD73c4404a2aBb14758154CB75D83732] = 236912348;
        tokenBalanceLedger_[0x1e8fD2c59794DCC4Da828A3bCdb60d89299E3cF9] = 1052830363;
        tokenBalanceLedger_[0x6035B5d20d199048E3506C39FedA2884C22A8310] = 2487705468;
        tokenBalanceLedger_[0x0405d13F31a23E551Cc090BAb668C30C37979986] = 1827355259;
        tokenBalanceLedger_[0x8f00412B7DecB40b09A2be04EB0176104BDa6345] = 856616103;
        tokenBalanceLedger_[0x0E8316560ADa85933601C4Ca174E1b4846B8893e] = 850807572;
        tokenBalanceLedger_[0xB0d88b3eC207239Da648789cc23ECFda8906850d] = 4094486753;
        tokenBalanceLedger_[0x9814FF84B339A05eD9012669f3c83cD06B51c863] = 3458425180;
        tokenBalanceLedger_[0x1ECE8b43D8Bf4F191Db604830c2d53476BE5e8e0] = 5131417222;
        tokenBalanceLedger_[0xb38Ba721f92655701717Ae41DD73597a3D89F992] = 716335014;
        tokenBalanceLedger_[0xe124df636bB848e2A861Ee9B39Ea10AB91fc7d0a] = 171075007;
        tokenBalanceLedger_[0x1e91F0263b09049F1C940663781b5FB2162728C8] = 3448791131;
        tokenBalanceLedger_[0x31cc9E04D9E53ba0b30Abb39c66496CeA879A90f] = 90124572;
        tokenBalanceLedger_[0x2Ea8C9bcB691B5b0286Af71Bc8C3d7083EF59b53] = 169312696;
        tokenBalanceLedger_[0xC514D37EA3f613aa669dD6f4B6daa8795751006F] = 12628124256;
        tokenBalanceLedger_[0x84A3048C863aa9bf7b58e1D754AA27911bEbCDC7] = 13917867;
        tokenBalanceLedger_[0xe974cB98FBd4980F27C80fb6Dc27067F6B04b1C7] = 583345415;
        tokenBalanceLedger_[0xEa58c4810fA0c2328489254B70D43EBEC578dC5c] = 2904600051;
        tokenBalanceLedger_[0x76d7cBe6D51c5Aea8147DC11Fe474a840fc71Ce2] = 718272079;
        tokenBalanceLedger_[0xcBf2B91779a3e2C82026D3575A9C1E0aAAa99a9D] = 120202208;
        tokenBalanceLedger_[0xdd69F5609Bd36161Ac0793Cb92B4c0BaE9993e72] = 38362371;
        tokenBalanceLedger_[0xC4E0789750295C70cdaf5d7e0006cC3d597Cd310] = 1701463986;
        tokenBalanceLedger_[0x82305e850f648D11401738BC94Bee7ffDAC49102] = 8168548;
        tokenBalanceLedger_[0x860a07bD229ba784aBb28ADC7fCcC796C93B49DA] = 116318686;
        tokenBalanceLedger_[0xd0E675469aDEd5f0287Bbbf3e295807793F39bD8] = 42893518;
        tokenBalanceLedger_[0x4CB1bA572Eb406b2F9040CDC37F380923c7e4030] = 706026551;
        tokenBalanceLedger_[0xB4D32A4B1f1Fd35aCd0feBdE172103788f3aA8C4] = 10064176;
        tokenBalanceLedger_[0x5D91eA5236c4C9f8615187e2909fe6137cCfA9A6] = 128103392;
        tokenBalanceLedger_[0x23e5A169DFEBD287Ff0DF8a022d23E84E05bd97c] = 130176593;
        tokenBalanceLedger_[0x138b8FcfCDce162CDc46C9408dcC060C74275034] = 33694503;
        tokenBalanceLedger_[0x1D74Ce35aaa4522afB1A92eF71483656Ba9CaFc8] = 126259876;
        tokenBalanceLedger_[0x049d9B4A5F56A2423362eEa9a3D38D8361A1FEDA] = 340536862;
        tokenBalanceLedger_[0x4e642898D58Fa6d0EaCD689a7c1d04124848240b] = 126318679;
        tokenBalanceLedger_[0xF7e5e236A64b09Ae9e23568B44c0607FA7682bA4] = 295852704;
        tokenBalanceLedger_[0xb4514C4332f793619f83E854c18D208e2a10dAF4] = 155374778;
        tokenBalanceLedger_[0x0Abc1fDb38AD29c788412d035778F852Cb7F92d7] = 10606048;
        tokenBalanceLedger_[0x8754005064486F98BE00823406A97E0Be6956c8F] = 1241181514;
        tokenBalanceLedger_[0xbabbb80F4Fa952DC5Cb3E862BB2de805ebcCA910] = 317870403;
        tokenBalanceLedger_[0x96d7F56c29c0f93B9EB3f9C9BEc2aF992E58947b] = 9000;
        tokenBalanceLedger_[0x98504FF45ddFC6708dCa1defDde972C24d8b06E3] = 2124310365;
        tokenBalanceLedger_[0x0a0929fe4370B3f24238e758F3826Fe222C2f42A] = 117377381;
        tokenBalanceLedger_[0x8CaA461b10e74a62baac4779a146a92d9aDa6A78] = 64043886;
        tokenBalanceLedger_[0xE83E7818aaFfEdf78fD0cC79F050f19CE4548220] = 518260456;
        tokenBalanceLedger_[0x099c420635b93A824066733a923C4f40E7496EA5] = 103009795;
        tokenBalanceLedger_[0x26162173917a277b9542173E416d19d4541A8347] = 78932701;
        tokenBalanceLedger_[0xB62FA834C321E55ff7b4e5e8e52af5532cFafE79] = 11052570;
        tokenBalanceLedger_[0x06352daBBdD25dC08C632b55b6EAbF19C39e59aC] = 10800000;
        tokenBalanceLedger_[0xBf0c2653bC1dF673eF990e5dEFe576EC03dbbf82] = 45851951;
        tokenBalanceLedger_[0xB644e92718D9c9eABD59AfF1B2e97e3A6a0f42e6] = 1185917253;
        tokenBalanceLedger_[0x9c0383459F9D122A5Ca3bad8cAB557b00B6f6862] = 2685481;
        tokenBalanceLedger_[0x3172D0b99d5a3B7B10BF47783bD79c7B532C04Bf] = 46505150;
        tokenBalanceLedger_[0xAACB4E7514aAaC78B7Fd8D5AFB2c1be78ad9B093] = 10800000;
        tokenBalanceLedger_[0xB53E6eF1Bf6227B62e10c7bfca708cCFe5Edf9b4] = 38308532;
        tokenBalanceLedger_[0x9721B94B41E0f70b8915Ba0076c2510DDBbf45aA] = 77109500;
        tokenBalanceLedger_[0x50541e1575Ca916cD2E3713965a3367a034848b1] = 156596785;
        tokenBalanceLedger_[0xd15edc3ce5b5f39aCF7D905E95783e52e567c408] = 34549936;
        tokenBalanceLedger_[0xe9e20771E340b37F7F9bDA651Ac90b8fA40Ab338] = 2169272838;
        tokenBalanceLedger_[0x1d1dfB21213495D7D6b38802019dE7A1aAF18ceE] = 22500000;
        tokenBalanceLedger_[0x88D3971545ADDe680fB0632ddB5cCb90180a2E37] = 127800000;
        tokenBalanceLedger_[0xF8e4B7239b1560209d35f0A00977Df63929aaa67] = 489324575;
        tokenBalanceLedger_[0x4fA24872A199a819e3C0E39F5DE9B626F9b5bBD3] = 100080000;
        tokenBalanceLedger_[0xB3F8280dF373B3a8591ec3A5153eD1A1FEF31708] = 13056649;
        tokenBalanceLedger_[0xBCB15FA3d1665688C4c0A7aDcd0a0f9c73518587] = 45000000;
        tokenBalanceLedger_[0x2C9dA8a1E706410B7c3d98DBb406A591a5ad9090] = 131491048;
        tokenBalanceLedger_[0x0a419ee410365D16e50dbEf70978D46D69B9bF3A] = 33449796;
        tokenBalanceLedger_[0x2CDb5347d04EBe4fe2945660B7bE63a31615A99d] = 199989659;
        tokenBalanceLedger_[0x2680Ad9E16901bb0df63dae0637Bbc9d423E8d7b] = 98047484;
        tokenBalanceLedger_[0x8BE9C171C64778d8BCA50a5B025744c6F29F5d60] = 50000000;
        tokenBalanceLedger_[0x7862883C299dc195180fDaCbeBC3D31892c2F94c] = 107036119;
        tokenBalanceLedger_[0x98fE7C915dec05edcEe970A867795d0d61a3193C] = 95063207;
        
        // The rest of the state was too large to fit in the constructor itself 
        // so the admin will be calling the transactions for that indivisually for each user
        // using the functions setInitialCursorState, setInitialTimestampedBalanceState
        // and setInitialPayoutsState
        // Then the initial stage is disabled so that the admins don't keep the right to change the contract state

    }


    bool public areCursorSet = false;
    function setInitialCursorState()
      public
      onlyAdministratorIntialStage()
    {
        if(!areCursorSet){

            tokenTimestampedBalanceCursor[0x5716d088a6E3f30FdC8c08eA5c519C103D2BBC24].end = 102;
            tokenTimestampedBalanceCursor[0x45De5dFb0E13d6933Afed37870BE6eaf87b4cDEe].end = 11;
            tokenTimestampedBalanceCursor[0x977C7C7356bB046c66d42977da76FdD919B13968].end = 70;
            tokenTimestampedBalanceCursor[0xfafAa13890452fA444959798302ff8A2d207915d].end = 21;
            tokenTimestampedBalanceCursor[0xc5f6Bb13B0C2B293391195D04945c6c85708C61a].end = 14;
            tokenTimestampedBalanceCursor[0xc0c6B3d8F93C348474Aee5328d7aB9BECB7dAeAc].end = 28;
            tokenTimestampedBalanceCursor[0x0Fc480eB1fC590a37647275529B875417C1e4f06].end = 22;
            tokenTimestampedBalanceCursor[0xdafD17E58f48D462BC7F271A3eee7486B419A632].end = 38;
            tokenTimestampedBalanceCursor[0x0Cfc783943553a0c91A68d46f9c971128D7d8Aee].end = 5;
            tokenTimestampedBalanceCursor[0x47f06D6269B2fca8238326C26Ef8D5663A2DEde8].end = 11;
            tokenTimestampedBalanceCursor[0x7C6E870fBD73c4404a2aBb14758154CB75D83732].end = 5;
            tokenTimestampedBalanceCursor[0x1e8fD2c59794DCC4Da828A3bCdb60d89299E3cF9].end = 11;
            tokenTimestampedBalanceCursor[0x6035B5d20d199048E3506C39FedA2884C22A8310].end = 17;
            tokenTimestampedBalanceCursor[0x0405d13F31a23E551Cc090BAb668C30C37979986].end = 11;
            tokenTimestampedBalanceCursor[0x8f00412B7DecB40b09A2be04EB0176104BDa6345].end = 12;
            tokenTimestampedBalanceCursor[0x0E8316560ADa85933601C4Ca174E1b4846B8893e].end = 18;
            tokenTimestampedBalanceCursor[0xB0d88b3eC207239Da648789cc23ECFda8906850d].end = 15;
            tokenTimestampedBalanceCursor[0x9814FF84B339A05eD9012669f3c83cD06B51c863].end = 24;
            tokenTimestampedBalanceCursor[0x1ECE8b43D8Bf4F191Db604830c2d53476BE5e8e0].end = 33;
            tokenTimestampedBalanceCursor[0xb38Ba721f92655701717Ae41DD73597a3D89F992].end = 10;
            tokenTimestampedBalanceCursor[0xe124df636bB848e2A861Ee9B39Ea10AB91fc7d0a].end = 1;
            tokenTimestampedBalanceCursor[0x1e91F0263b09049F1C940663781b5FB2162728C8].end = 14;
            tokenTimestampedBalanceCursor[0x31cc9E04D9E53ba0b30Abb39c66496CeA879A90f].end = 9;
            tokenTimestampedBalanceCursor[0x2Ea8C9bcB691B5b0286Af71Bc8C3d7083EF59b53].end = 16;
            tokenTimestampedBalanceCursor[0xC514D37EA3f613aa669dD6f4B6daa8795751006F].end = 8;
            tokenTimestampedBalanceCursor[0x84A3048C863aa9bf7b58e1D754AA27911bEbCDC7].end = 6;
            tokenTimestampedBalanceCursor[0xe974cB98FBd4980F27C80fb6Dc27067F6B04b1C7].end = 13;
            tokenTimestampedBalanceCursor[0xEa58c4810fA0c2328489254B70D43EBEC578dC5c].end = 10;
            tokenTimestampedBalanceCursor[0x76d7cBe6D51c5Aea8147DC11Fe474a840fc71Ce2].end = 2;
            tokenTimestampedBalanceCursor[0xcBf2B91779a3e2C82026D3575A9C1E0aAAa99a9D].end = 19;
            tokenTimestampedBalanceCursor[0xdd69F5609Bd36161Ac0793Cb92B4c0BaE9993e72].end = 3;
            tokenTimestampedBalanceCursor[0xC4E0789750295C70cdaf5d7e0006cC3d597Cd310].end = 12;
            tokenTimestampedBalanceCursor[0x82305e850f648D11401738BC94Bee7ffDAC49102].end = 6;
            tokenTimestampedBalanceCursor[0x860a07bD229ba784aBb28ADC7fCcC796C93B49DA].end = 7;
            tokenTimestampedBalanceCursor[0xd0E675469aDEd5f0287Bbbf3e295807793F39bD8].end = 1;
            tokenTimestampedBalanceCursor[0x4CB1bA572Eb406b2F9040CDC37F380923c7e4030].end = 20;
            tokenTimestampedBalanceCursor[0xB4D32A4B1f1Fd35aCd0feBdE172103788f3aA8C4].end = 3;
            tokenTimestampedBalanceCursor[0x5D91eA5236c4C9f8615187e2909fe6137cCfA9A6].end = 3;
            tokenTimestampedBalanceCursor[0x23e5A169DFEBD287Ff0DF8a022d23E84E05bd97c].end = 5;
            tokenTimestampedBalanceCursor[0x138b8FcfCDce162CDc46C9408dcC060C74275034].end = 1;
            tokenTimestampedBalanceCursor[0x1D74Ce35aaa4522afB1A92eF71483656Ba9CaFc8].end = 1;
            tokenTimestampedBalanceCursor[0x049d9B4A5F56A2423362eEa9a3D38D8361A1FEDA].end = 17;
            tokenTimestampedBalanceCursor[0x4e642898D58Fa6d0EaCD689a7c1d04124848240b].end = 12;
            tokenTimestampedBalanceCursor[0xF7e5e236A64b09Ae9e23568B44c0607FA7682bA4].end = 7;
            tokenTimestampedBalanceCursor[0xb4514C4332f793619f83E854c18D208e2a10dAF4].end = 3;
            tokenTimestampedBalanceCursor[0x0Abc1fDb38AD29c788412d035778F852Cb7F92d7].end = 3;
            tokenTimestampedBalanceCursor[0x8754005064486F98BE00823406A97E0Be6956c8F].end = 15;
            tokenTimestampedBalanceCursor[0xbabbb80F4Fa952DC5Cb3E862BB2de805ebcCA910].end = 5;
            tokenTimestampedBalanceCursor[0x96d7F56c29c0f93B9EB3f9C9BEc2aF992E58947b].end = 1;
            tokenTimestampedBalanceCursor[0x98504FF45ddFC6708dCa1defDde972C24d8b06E3].end = 11;
            tokenTimestampedBalanceCursor[0x0a0929fe4370B3f24238e758F3826Fe222C2f42A].end = 5;
            tokenTimestampedBalanceCursor[0x8CaA461b10e74a62baac4779a146a92d9aDa6A78].end = 7;
            tokenTimestampedBalanceCursor[0xE83E7818aaFfEdf78fD0cC79F050f19CE4548220].end = 7;
            tokenTimestampedBalanceCursor[0x099c420635b93A824066733a923C4f40E7496EA5].end = 4;
            tokenTimestampedBalanceCursor[0x26162173917a277b9542173E416d19d4541A8347].end = 3;
            tokenTimestampedBalanceCursor[0xB62FA834C321E55ff7b4e5e8e52af5532cFafE79].end = 2;
            tokenTimestampedBalanceCursor[0x06352daBBdD25dC08C632b55b6EAbF19C39e59aC].end = 1;
            tokenTimestampedBalanceCursor[0xBf0c2653bC1dF673eF990e5dEFe576EC03dbbf82].end = 5;
            tokenTimestampedBalanceCursor[0xB644e92718D9c9eABD59AfF1B2e97e3A6a0f42e6].end = 6;
            tokenTimestampedBalanceCursor[0x9c0383459F9D122A5Ca3bad8cAB557b00B6f6862].end = 1;
            tokenTimestampedBalanceCursor[0x3172D0b99d5a3B7B10BF47783bD79c7B532C04Bf].end = 3;
            tokenTimestampedBalanceCursor[0xAACB4E7514aAaC78B7Fd8D5AFB2c1be78ad9B093].end = 1;
            tokenTimestampedBalanceCursor[0xB53E6eF1Bf6227B62e10c7bfca708cCFe5Edf9b4].end = 1;
            tokenTimestampedBalanceCursor[0x9721B94B41E0f70b8915Ba0076c2510DDBbf45aA].end = 4;
            tokenTimestampedBalanceCursor[0x50541e1575Ca916cD2E3713965a3367a034848b1].end = 6;
            tokenTimestampedBalanceCursor[0xd15edc3ce5b5f39aCF7D905E95783e52e567c408].end = 4;
            tokenTimestampedBalanceCursor[0xe9e20771E340b37F7F9bDA651Ac90b8fA40Ab338].end = 7;
            tokenTimestampedBalanceCursor[0x1d1dfB21213495D7D6b38802019dE7A1aAF18ceE].end = 1;
            tokenTimestampedBalanceCursor[0x88D3971545ADDe680fB0632ddB5cCb90180a2E37].end = 2;
            tokenTimestampedBalanceCursor[0xF8e4B7239b1560209d35f0A00977Df63929aaa67].end = 4;
            tokenTimestampedBalanceCursor[0x4fA24872A199a819e3C0E39F5DE9B626F9b5bBD3].end = 1;
            tokenTimestampedBalanceCursor[0xB3F8280dF373B3a8591ec3A5153eD1A1FEF31708].end = 3;
            tokenTimestampedBalanceCursor[0xBCB15FA3d1665688C4c0A7aDcd0a0f9c73518587].end = 1;
            tokenTimestampedBalanceCursor[0x2C9dA8a1E706410B7c3d98DBb406A591a5ad9090].end = 1;
            tokenTimestampedBalanceCursor[0x0a419ee410365D16e50dbEf70978D46D69B9bF3A].end = 2;
            tokenTimestampedBalanceCursor[0x2CDb5347d04EBe4fe2945660B7bE63a31615A99d].end = 5;
            tokenTimestampedBalanceCursor[0x2680Ad9E16901bb0df63dae0637Bbc9d423E8d7b].end = 1;
            tokenTimestampedBalanceCursor[0x8BE9C171C64778d8BCA50a5B025744c6F29F5d60].end = 1;
            tokenTimestampedBalanceCursor[0x7862883C299dc195180fDaCbeBC3D31892c2F94c].end = 2;
            tokenTimestampedBalanceCursor[0x98fE7C915dec05edcEe970A867795d0d61a3193C].end = 2;

            areCursorSet = true;
        }
    }

    bool public arePayoutsSet = false;
    function setInitialPayoutsState()
      public
      onlyAdministratorIntialStage()
    {
        if(!arePayoutsSet){

            payoutsTo_[0x5716d088a6E3f30FdC8c08eA5c519C103D2BBC24] = 1436024646628593389366633447904;
            payoutsTo_[0x45De5dFb0E13d6933Afed37870BE6eaf87b4cDEe] = 14913563948781233480056009397;
            payoutsTo_[0x977C7C7356bB046c66d42977da76FdD919B13968] = 124214221831524229885313313231;
            payoutsTo_[0xfafAa13890452fA444959798302ff8A2d207915d] = 279296588357317867619017766338;
            payoutsTo_[0xc5f6Bb13B0C2B293391195D04945c6c85708C61a] = 15831052597537017452883768280;
            payoutsTo_[0xc0c6B3d8F93C348474Aee5328d7aB9BECB7dAeAc] = 220358253647232419309550060067;
            payoutsTo_[0x0Fc480eB1fC590a37647275529B875417C1e4f06] = 109181662029474509168341877756;
            payoutsTo_[0xdafD17E58f48D462BC7F271A3eee7486B419A632] = 151220989577833544104103028334;
            payoutsTo_[0x0Cfc783943553a0c91A68d46f9c971128D7d8Aee] = 5974804108685494182815602158;
            payoutsTo_[0x47f06D6269B2fca8238326C26Ef8D5663A2DEde8] = 23165593640447248103184733239;
            payoutsTo_[0x7C6E870fBD73c4404a2aBb14758154CB75D83732] = 5859653662509333583242156202;
            payoutsTo_[0x1e8fD2c59794DCC4Da828A3bCdb60d89299E3cF9] = 25712383484856198268295080270;
            payoutsTo_[0x6035B5d20d199048E3506C39FedA2884C22A8310] = 61613212893879787805700455536;
            payoutsTo_[0x0405d13F31a23E551Cc090BAb668C30C37979986] = 44627643373669836665230470142;
            payoutsTo_[0x8f00412B7DecB40b09A2be04EB0176104BDa6345] = 20755313278523727492689528449;
            payoutsTo_[0x0E8316560ADa85933601C4Ca174E1b4846B8893e] = 18172294740257808226485409030;
            payoutsTo_[0xB0d88b3eC207239Da648789cc23ECFda8906850d] = 100965549212234468155112508029;
            payoutsTo_[0x9814FF84B339A05eD9012669f3c83cD06B51c863] = 85406776092754351007254925605;
            payoutsTo_[0x1ECE8b43D8Bf4F191Db604830c2d53476BE5e8e0] = 127031074842632227509839144918;
            payoutsTo_[0xb38Ba721f92655701717Ae41DD73597a3D89F992] = 17446233301522394030247011896;
            payoutsTo_[0xe124df636bB848e2A861Ee9B39Ea10AB91fc7d0a] = 1681969465994759870765862172;
            payoutsTo_[0x1e91F0263b09049F1C940663781b5FB2162728C8] = 83900620824064460201979068197;
            payoutsTo_[0x31cc9E04D9E53ba0b30Abb39c66496CeA879A90f] = 2232306659352691146055108531;
            payoutsTo_[0x2Ea8C9bcB691B5b0286Af71Bc8C3d7083EF59b53] = 4197655697705249688475619718;
            payoutsTo_[0xC514D37EA3f613aa669dD6f4B6daa8795751006F] = 191404876536992063556198110650;
            payoutsTo_[0x84A3048C863aa9bf7b58e1D754AA27911bEbCDC7] = 297979068973433987932504325;
            payoutsTo_[0xe974cB98FBd4980F27C80fb6Dc27067F6B04b1C7] = 14462491767323645546929943052;
            payoutsTo_[0xEa58c4810fA0c2328489254B70D43EBEC578dC5c] = 70744412519100109016263913316;
            payoutsTo_[0x76d7cBe6D51c5Aea8147DC11Fe474a840fc71Ce2] = 10433427582088396392529016786;
            payoutsTo_[0xcBf2B91779a3e2C82026D3575A9C1E0aAAa99a9D] = 2977301532322270347975241895;
            payoutsTo_[0xdd69F5609Bd36161Ac0793Cb92B4c0BaE9993e72] = 665442117483468428852953018;
            payoutsTo_[0xC4E0789750295C70cdaf5d7e0006cC3d597Cd310] = 42077373021950789698386525824;
            payoutsTo_[0x82305e850f648D11401738BC94Bee7ffDAC49102] = 135940680212915259897160956;
            payoutsTo_[0x860a07bD229ba784aBb28ADC7fCcC796C93B49DA] = 2884107001828553489307413721;
            payoutsTo_[0xd0E675469aDEd5f0287Bbbf3e295807793F39bD8] = 919717468147010825231317650;
            payoutsTo_[0x4CB1bA572Eb406b2F9040CDC37F380923c7e4030] = 17411668165869141870381096809;
            payoutsTo_[0xB4D32A4B1f1Fd35aCd0feBdE172103788f3aA8C4] = 161249187815771658050907948;
            payoutsTo_[0x5D91eA5236c4C9f8615187e2909fe6137cCfA9A6] = 2188037399101180873641357075;
            payoutsTo_[0x23e5A169DFEBD287Ff0DF8a022d23E84E05bd97c] = 3219774712229562691934190669;
            payoutsTo_[0x138b8FcfCDce162CDc46C9408dcC060C74275034] = 525354938119153670693269923;
            payoutsTo_[0x1D74Ce35aaa4522afB1A92eF71483656Ba9CaFc8] = 1969479355789913595949993120;
            payoutsTo_[0x049d9B4A5F56A2423362eEa9a3D38D8361A1FEDA] = 8371565715199059248612476252;
            payoutsTo_[0x4e642898D58Fa6d0EaCD689a7c1d04124848240b] = 2689215747495881737410628160;
            payoutsTo_[0xF7e5e236A64b09Ae9e23568B44c0607FA7682bA4] = 6306017268591681736453043269;
            payoutsTo_[0xb4514C4332f793619f83E854c18D208e2a10dAF4] = 2970802437512452782246639402;
            payoutsTo_[0x0Abc1fDb38AD29c788412d035778F852Cb7F92d7] = 262057533516595451747434244;
            payoutsTo_[0x8754005064486F98BE00823406A97E0Be6956c8F] = 30608030793550231897888453471;
            payoutsTo_[0xbabbb80F4Fa952DC5Cb3E862BB2de805ebcCA910] = 6099007815654530994004620338;
            payoutsTo_[0x96d7F56c29c0f93B9EB3f9C9BEc2aF992E58947b] = 149939480048143348332000;
            payoutsTo_[0x98504FF45ddFC6708dCa1defDde972C24d8b06E3] = 52615498397714888844960140813;
            payoutsTo_[0x0a0929fe4370B3f24238e758F3826Fe222C2f42A] = 2889894639181875913042508099;
            payoutsTo_[0x8CaA461b10e74a62baac4779a146a92d9aDa6A78] = 1586270383483729084597594195;
            payoutsTo_[0xE83E7818aaFfEdf78fD0cC79F050f19CE4548220] = 12797988621174697480123119504;
            payoutsTo_[0x099c420635b93A824066733a923C4f40E7496EA5] = 2543900243758082833989068581;
            payoutsTo_[0x26162173917a277b9542173E416d19d4541A8347] = 1949464994314474988957045843;
            payoutsTo_[0xB62FA834C321E55ff7b4e5e8e52af5532cFafE79] = 272950498819184843107597650;
            payoutsTo_[0x06352daBBdD25dC08C632b55b6EAbF19C39e59aC] = 188537884807507897759200000;
            payoutsTo_[0xBf0c2653bC1dF673eF990e5dEFe576EC03dbbf82] = 1069291000373241199308179446;
            payoutsTo_[0xB644e92718D9c9eABD59AfF1B2e97e3A6a0f42e6] = 29327913099886085674304797261;
            payoutsTo_[0x9c0383459F9D122A5Ca3bad8cAB557b00B6f6862] = 47638621671205537151619863;
            payoutsTo_[0x3172D0b99d5a3B7B10BF47783bD79c7B532C04Bf] = 1149084299482498912528185992;
            payoutsTo_[0xAACB4E7514aAaC78B7Fd8D5AFB2c1be78ad9B093] = 191907802402139632010400000;
            payoutsTo_[0xB53E6eF1Bf6227B62e10c7bfca708cCFe5Edf9b4] = 680845664170532714772625692;
            payoutsTo_[0x9721B94B41E0f70b8915Ba0076c2510DDBbf45aA] = 1907128299636338490643406579;
            payoutsTo_[0x50541e1575Ca916cD2E3713965a3367a034848b1] = 3848939199471285441295095363;
            payoutsTo_[0xd15edc3ce5b5f39aCF7D905E95783e52e567c408] = 854520262402097212146964555;
            payoutsTo_[0xe9e20771E340b37F7F9bDA651Ac90b8fA40Ab338] = 53318521417501383095350244845;
            payoutsTo_[0x1d1dfB21213495D7D6b38802019dE7A1aAF18ceE] = 412525809544253308267500000;
            payoutsTo_[0x88D3971545ADDe680fB0632ddB5cCb90180a2E37] = 2441167380276794250521400000;
            payoutsTo_[0xF8e4B7239b1560209d35f0A00977Df63929aaa67] = 12114088177465680828149315538;
            payoutsTo_[0x4fA24872A199a819e3C0E39F5DE9B626F9b5bBD3] = 2139866540490703285505520000;
            payoutsTo_[0xB3F8280dF373B3a8591ec3A5153eD1A1FEF31708] = 286420739814154509256897245;
            payoutsTo_[0xBCB15FA3d1665688C4c0A7aDcd0a0f9c73518587] = 987203297425276190025000000;
            payoutsTo_[0x2C9dA8a1E706410B7c3d98DBb406A591a5ad9090] = 3232563780947211124406917496;
            payoutsTo_[0x0a419ee410365D16e50dbEf70978D46D69B9bF3A] = 823552056753099823544564646;
            payoutsTo_[0x2CDb5347d04EBe4fe2945660B7bE63a31615A99d] = 4958226505676378586840904939;
            payoutsTo_[0x2680Ad9E16901bb0df63dae0637Bbc9d423E8d7b] = 2419117044283186558061318380;
            payoutsTo_[0x8BE9C171C64778d8BCA50a5B025744c6F29F5d60] = 1234903162470242434150000000;
            payoutsTo_[0x7862883C299dc195180fDaCbeBC3D31892c2F94c] = 2653556136152832199284806455;
            payoutsTo_[0x98fE7C915dec05edcEe970A867795d0d61a3193C] = 2358395758214932931236638584;

            arePayoutsSet = true;
        }
    }

    /**
     * Fallback function to handle tron that was send straight to the contract
     * Unfortunately we cannot use a referral address this way.
     */
    function() external payable {
        purchaseTokens(msg.sender, msg.value, address(0));
    }

    /**
     * The accounts which are acting as escrows can send the money back to the contract
     */
    function seedFunds() public payable {}

    function setInitialTimestampedBalanceState(
        address _customerAddress,
        uint256 value, 
        uint256 timestamp, 
        uint256 valueSold
    ) public 
      onlyAdministratorIntialStage()
    {
        tokenTimestampedBalanceLedger_[_customerAddress].push(
            TimestampedBalance(value, timestamp, valueSold)
        );
    }

    function disableInitialState() public onlyAdministrator()
    {
        adminCanChangeState = false;
    }

    /**
     * Converts all incoming tron to tokens for the caller, and passes down the referral addy (if any)
     */
    function buy(address _referredBy) public payable {
        purchaseTokens(msg.sender, msg.value, _referredBy);
    }

    /**
     * Converts all of caller's dividends to tokens.
     */
    function reinvest(
        bool isAutoReinvestChecked,
        uint24 period,
        uint256 rewardPerInvocation,
        uint256 minimumDividendValue
    ) public {
        _reinvest(msg.sender);

        // Setup Auto Reinvestment
        if (isAutoReinvestChecked) {
            _setupAutoReinvest(
                period,
                rewardPerInvocation,
                msg.sender,
                minimumDividendValue
            );
        }
    }

    /**
     * Alias of sell() and withdraw().
     */
    function exit() public {
        // get token count for caller & sell them all
        address _customerAddress = msg.sender;
        uint256 _tokens = tokenBalanceLedger_[_customerAddress];
        if (_tokens > 0) sell(_tokens);
        withdraw();
    }

    /**
     * Withdraws all of the callers earnings.
     */
    function withdraw() public {
        _withdraw(msg.sender);
    }

    /**
     * Liquifies tokens to tron.
     */
    function sell(uint256 _amountOfTokens) public onlyBagholders() {
        // setup data
        address _customerAddress = msg.sender;
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        uint256 _tokens = _amountOfTokens;
        uint256 _tron = tokensToTron_(_tokens);

        uint256 penalty =
            mulDiv(
                calculateAveragePenaltyAndUpdateLedger(
                    _amountOfTokens,
                    _customerAddress
                ),
                _tron,
                100
            );

        uint256 _dividends =
            SafeMath.add(
                penalty,
                SafeMath.div(SafeMath.sub(_tron, penalty), dividendFee_)
            );

        uint256 _taxedTron = SafeMath.sub(_tron, _dividends);

        // burn the sold tokens
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(
            tokenBalanceLedger_[_customerAddress],
            _tokens
        );

        // update dividends tracker
        int256 _updatedPayouts =
            (int256)(profitPerShare_ * _tokens + (_taxedTron * magnitude));
        payoutsTo_[_customerAddress] -= _updatedPayouts;

        if (tokenSupply_ > 0) {
            // update the amount of dividends per token
            profitPerShare_ = SafeMath.add(
                profitPerShare_,
                mulDiv(_dividends, magnitude, tokenSupply_)
            );
        }

        emit onTokenSell(_customerAddress, _tokens, _taxedTron);
    }

    /*----------  ADMINISTRATOR ONLY FUNCTIONS  ----------*/
    function setAdministrator(address _identifier, bool _status)
        public
        onlyAdministrator()
    {
        administrators[_identifier] = _status;
    }

    /**
     * Precautionary measures in case we need to adjust the masternode rate.
     */
    function setStakingRequirement(uint256 _amountOfTokens)
        public
        onlyAdministrator()
    {
        stakingRequirement = _amountOfTokens;
    }

    /**
     * If we want to rebrand, we can.
     */
    function setName(string memory _name) public onlyAdministrator() {
        name = _name;
    }

    /**
     * If we want to rebrand, we can.
     */
    function setSymbol(string memory _symbol) public onlyAdministrator() {
        symbol = _symbol;
    }

    /*----------  REFERRAL FUNCTIONS  ----------*/

    function setReferralName(bytes32 ref_name) public returns (bool) {
        referralMapping[msg.sender] = ref_name;
        referralReverseMapping[ref_name] = msg.sender;
        return true;
    }

    function getReferralAddressForName(bytes32 ref_name)
        public
        view
        returns (address)
    {
        return referralReverseMapping[ref_name];
    }

    function getReferralNameForAddress(address ref_address)
        public
        view
        returns (bytes32)
    {
        return referralMapping[ref_address];
    }

    function getReferralBalance() public view returns (uint256, uint256) {
        address _customerAddress = msg.sender;
        return (
            referralBalance_[_customerAddress],
            referralIncome_[_customerAddress]
        );
    }

    /*------READ FUNCTIONS FOR TIMESTAMPED BALANCE LEDGER-------*/

    function getCursor() public view returns (uint256, uint256) {
        address _customerAddress = msg.sender;
        Cursor storage cursor = tokenTimestampedBalanceCursor[_customerAddress];

        return (cursor.start, cursor.end);
    }

    function getTimestampedBalanceLedger(uint256 counter)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        address _customerAddress = msg.sender;
        TimestampedBalance storage transaction =
            tokenTimestampedBalanceLedger_[_customerAddress][counter];
        return (
            transaction.value,
            transaction.timestamp,
            transaction.valueSold
        );
    }

    /*----------  HELPERS AND CALCULATORS  ----------*/
    /**
     * Method to view the current Tron stored in the contract
     * Example: totalTronBalance()
     */
    function totalTronBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * Retrieve the total token supply.
     */
    function totalSupply() public view returns (uint256) {
        return tokenSupply_;
    }

    /**
     * Retrieve the tokens owned by the caller.
     */
    function myTokens() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }

    /**
     * Retrieve the dividends owned by the caller.
     * If `_includeReferralBonus` is true, the referral bonus will be included in the calculations.
     * The reason for this, is that in the frontend, we will want to get the total divs (global + ref)
     * But in the internal calculations, we want them separate.
     */
    function myDividends(bool _includeReferralBonus)
        public
        view
        returns (uint256)
    {
        address _customerAddress = msg.sender;
        return
            _includeReferralBonus
                ? dividendsOf(_customerAddress) +
                    referralBalance_[_customerAddress]
                : dividendsOf(_customerAddress);
    }

    /**
     * Retrieve the token balance of any single address.
     */
    function balanceOf(address _customerAddress) public view returns (uint256) {
        return tokenBalanceLedger_[_customerAddress];
    }

    /**
     * Retrieve the dividend balance of any single address.
     */
    function dividendsOf(address _customerAddress)
        public
        view
        returns (uint256)
    {
        return
            (uint256)(
                (int256)(
                    profitPerShare_ * tokenBalanceLedger_[_customerAddress]
                ) - payoutsTo_[_customerAddress]
            ) / magnitude;
    }

    /**
     * Return the tron received on selling 1 individual token.
     * We are not deducting the penalty over here as it's a general sell price
     * the user can use the `calculateTronReceived` to get the sell price specific to them
     */
    function sellPrice() public view returns (uint256) {
        if (tokenSupply_ == 0) {
            return tokenPriceInitial_ - tokenPriceIncremental_;
        } else {
            uint256 _tron = tokensToTron_(1e6);
            uint256 _dividends = SafeMath.div(_tron, dividendFee_);
            uint256 _taxedTron = SafeMath.sub(_tron, _dividends);
            return _taxedTron;
        }
    }

    /**
     * Return the tron required for buying 1 individual token.
     */
    function buyPrice() public view returns (uint256) {
        if (tokenSupply_ == 0) {
            return tokenPriceInitial_ + tokenPriceIncremental_;
        } else {
            uint256 _tron = tokensToTron_(1e6);
            uint256 _taxedTron =
                mulDiv(_tron, dividendFee_, (dividendFee_ - 1));
            return _taxedTron;
        }
    }

    /*
     * Function for the frontend to dynamically retrieve the price scaling of buy orders.
     */
    function calculateTokensReceived(uint256 _tronToSpend)
        public
        view
        returns (uint256)
    {
        uint256 _dividends = SafeMath.div(_tronToSpend, dividendFee_);
        uint256 _taxedTron = SafeMath.sub(_tronToSpend, _dividends);
        uint256 _amountOfTokens = tronToTokens_(_taxedTron);
        return _amountOfTokens;
    }

    function calculateTokensReinvested() public view returns (uint256) {
        uint256 _tronToSpend = myDividends(true);
        uint256 _dividends = SafeMath.div(_tronToSpend, dividendFee_);
        uint256 _taxedTron = SafeMath.sub(_tronToSpend, _dividends);
        uint256 _amountOfTokens = tronToTokens_(_taxedTron);
        return _amountOfTokens;
    }

    /**
     * Function for the frontend to dynamically retrieve the price scaling of sell orders.
     */
    function calculateTronReceived(uint256 _tokensToSell)
        public
        view
        returns (uint256)
    {
        require(_tokensToSell <= tokenSupply_);
        require(_tokensToSell <= myTokens());
        uint256 _tron = tokensToTron_(_tokensToSell);
        address _customerAddress = msg.sender;

        uint256 penalty =
            mulDiv(
                calculateAveragePenalty(_tokensToSell, _customerAddress),
                _tron,
                100
            );

        uint256 _dividends =
            SafeMath.add(
                penalty,
                SafeMath.div(SafeMath.sub(_tron, penalty), dividendFee_)
            );

        uint256 _taxedTron = SafeMath.sub(_tron, _dividends);
        return _taxedTron;
    }

    function calculateTronTransferred(uint256 _amountOfTokens)
        public
        view
        returns (uint256)
    {
        require(_amountOfTokens <= tokenSupply_);
        require(_amountOfTokens <= myTokens());
        uint256 _tokenFee = SafeMath.div(_amountOfTokens, dividendFee_);
        uint256 _taxedTokens = SafeMath.sub(_amountOfTokens, _tokenFee);
        return _taxedTokens;
    }

    /**
     * Calculate the early exit penalty for selling x tokens
     */
    function calculateAveragePenalty(
        uint256 _amountOfTokens,
        address _customerAddress
    ) public view onlyBagholders() returns (uint256) {
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);

        uint256 tokensFound = 0;
        Cursor storage _customerCursor =
            tokenTimestampedBalanceCursor[_customerAddress];
        uint256 counter = _customerCursor.start;
        uint256 averagePenalty = 0;

        while (counter <= _customerCursor.end) {
            TimestampedBalance storage transaction =
                tokenTimestampedBalanceLedger_[_customerAddress][counter];
            uint256 tokensAvailable =
                SafeMath.sub(transaction.value, transaction.valueSold);

            uint256 tokensRequired = SafeMath.sub(_amountOfTokens, tokensFound);

            if (tokensAvailable < tokensRequired) {
                tokensFound += tokensAvailable;
                averagePenalty = SafeMath.add(
                    averagePenalty,
                    SafeMath.mul(
                        _calculatePenalty(transaction.timestamp),
                        tokensAvailable
                    )
                );
            } else if (tokensAvailable <= tokensRequired) {
                averagePenalty = SafeMath.add(
                    averagePenalty,
                    SafeMath.mul(
                        _calculatePenalty(transaction.timestamp),
                        tokensRequired
                    )
                );
                break;
            } else {
                averagePenalty = SafeMath.add(
                    averagePenalty,
                    SafeMath.mul(
                        _calculatePenalty(transaction.timestamp),
                        tokensRequired
                    )
                );
                break;
            }

            counter = SafeMath.add(counter, 1);
        }
        return SafeMath.div(averagePenalty, _amountOfTokens);
    }

    /**
     * Calculate the early exit penalty for selling after x days
     */
    function _calculatePenalty(uint256 timestamp)
        public
        view
        returns (uint256)
    {
        uint256 gap = block.timestamp - timestamp;

        if (gap > 30 days) {
            return 0;
        } else if (gap > 20 days) {
            return 25;
        } else if (gap > 10 days) {
            return 50;
        }
        return 75;
    }

    /**
     * Calculate Token price based on an amount of incoming tron
     * Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.
     */
    function tronToTokens_(uint256 _tron) public view returns (uint256) {
        uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e6;
        uint256 _tokensReceived =
            ((
                SafeMath.sub(
                    (
                        sqrt(
                            (_tokenPriceInitial**2) +
                                (2 *
                                    (tokenPriceIncremental_ * 1e6) *
                                    (_tron * 1e6)) +
                                (((tokenPriceIncremental_)**2) *
                                    (tokenSupply_**2)) +
                                (2 *
                                    (tokenPriceIncremental_) *
                                    _tokenPriceInitial *
                                    tokenSupply_)
                        )
                    ),
                    _tokenPriceInitial
                )
            ) / (tokenPriceIncremental_)) - (tokenSupply_);

        return _tokensReceived;
    }

    /**
     * Calculate token sell value.
     * Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.
     */
    function tokensToTron_(uint256 _tokens) public view returns (uint256) {
        uint256 tokens_ = (_tokens + 1e6);
        uint256 _tokenSupply = (tokenSupply_ + 1e6);
        uint256 _tronReceived =
            (SafeMath.sub(
                (((tokenPriceInitial_ +
                    (tokenPriceIncremental_ * (_tokenSupply / 1e6))) -
                    tokenPriceIncremental_) * (tokens_ - 1e6)),
                (tokenPriceIncremental_ * ((tokens_**2 - tokens_) / 1e6)) / 2
            ) / 1e6);

        return _tronReceived;
    }

    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/
    function purchaseTokens(
        address _customerAddress,
        uint256 _incomingTron,
        address _referredBy
    ) internal returns (uint256) {
        // data setup
        // address _customerAddress = msg.sender;
        uint256 _undividedDividends = SafeMath.div(_incomingTron, dividendFee_);
        uint256 _referralBonus = SafeMath.div(_undividedDividends, 3);
        uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);
        uint256 _taxedTron = SafeMath.sub(_incomingTron, _undividedDividends);
        uint256 _amountOfTokens = tronToTokens_(_taxedTron);
        uint256 _fee = _dividends * magnitude;

        require(
            _amountOfTokens > 0 &&
                SafeMath.add(_amountOfTokens, tokenSupply_) > tokenSupply_
        );

        // is the user referred by a masternode?
        if (
            _referredBy != address(0) &&
            _referredBy != _customerAddress &&
            tokenBalanceLedger_[_referredBy] >= stakingRequirement
        ) {
            // wealth redistribution
            referralBalance_[_referredBy] = SafeMath.add(
                referralBalance_[_referredBy],
                _referralBonus
            );
            referralIncome_[_referredBy] = SafeMath.add(
                referralIncome_[_referredBy],
                _referralBonus
            );
        } else {
            // no ref purchase
            // add the referral bonus back to the global dividends cake
            _dividends = SafeMath.add(_dividends, _referralBonus);
            _fee = _dividends * magnitude;
        }

        if (tokenSupply_ > 0) {
            // add tokens to the pool
            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);

            // take the amount of dividends gained through this transaction, and allocates them evenly to each shareholder
            profitPerShare_ += ((_dividends * magnitude) / (tokenSupply_));

            // calculate the amount of tokens the customer receives over his purchase
            _fee =
                _fee -
                (_fee -
                    (_amountOfTokens *
                        ((_dividends * magnitude) / (tokenSupply_))));
        } else {
            // add tokens to the pool
            tokenSupply_ = _amountOfTokens;
        }

        // update circulating supply & the ledger address for the customer
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(
            tokenBalanceLedger_[_customerAddress],
            _amountOfTokens
        );
        tokenTimestampedBalanceLedger_[_customerAddress].push(
            TimestampedBalance(_amountOfTokens, block.timestamp, 0)
        );
        tokenTimestampedBalanceCursor[_customerAddress].end += 1;

        // You don't get dividends for the tokens before they owned them
        int256 _updatedPayouts =
            (int256)(profitPerShare_ * _amountOfTokens - _fee);
        payoutsTo_[_customerAddress] += _updatedPayouts;

        // fire event
        emit onTokenPurchase(
            _customerAddress,
            _incomingTron,
            _amountOfTokens,
            _referredBy
        );

        emit Transfer(
            address(0),
            _customerAddress,
            _amountOfTokens
        );

        return _amountOfTokens;
    }

    function _reinvest(address _customerAddress) internal {
        uint256 _dividends = dividendsOf(_customerAddress);

        // onlyStronghands
        require(_dividends + referralBalance_[_customerAddress] > 0);

        payoutsTo_[_customerAddress] += (int256)(_dividends * magnitude);

        // retrieve ref. bonus
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;

        // dispatch a buy order with the virtualized "withdrawn dividends"
        uint256 _tokens =
            purchaseTokens(_customerAddress, _dividends, address(0));

        // fire event
        emit onReinvestment(_customerAddress, _dividends, _tokens);
    }

    function _withdraw(address _customerAddress) internal {
        uint256 _dividends = dividendsOf(_customerAddress); // get ref. bonus later in the code

        // onlyStronghands
        require(_dividends + referralBalance_[_customerAddress] > 0);

        // update dividend tracker
        payoutsTo_[_customerAddress] += (int256)(_dividends * magnitude);

        // add ref. bonus
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;

        address payable _payableCustomerAddress =
            address(uint160(_customerAddress));
        _payableCustomerAddress.transfer(_dividends);

        // fire event
        emit onWithdraw(_customerAddress, _dividends);
    }

    /**
     * Update ledger after transferring x tokens
     */
    function _updateLedgerForTransfer(
        uint256 _amountOfTokens,
        address _customerAddress
    ) internal {
        // Parse through the list of transactions
        uint256 tokensFound = 0;
        Cursor storage _customerCursor =
            tokenTimestampedBalanceCursor[_customerAddress];
        uint256 counter = _customerCursor.start;

        while (counter <= _customerCursor.end) {
            TimestampedBalance storage transaction =
                tokenTimestampedBalanceLedger_[_customerAddress][counter];
            uint256 tokensAvailable =
                SafeMath.sub(transaction.value, transaction.valueSold);

            uint256 tokensRequired = SafeMath.sub(_amountOfTokens, tokensFound);

            if (tokensAvailable < tokensRequired) {
                tokensFound += tokensAvailable;

                delete tokenTimestampedBalanceLedger_[_customerAddress][
                    counter
                ];
            } else if (tokensAvailable <= tokensRequired) {
                delete tokenTimestampedBalanceLedger_[_customerAddress][
                    counter
                ];
                _customerCursor.start = counter + 1;
                break;
            } else {
                transaction.valueSold += tokensRequired;
                _customerCursor.start = counter;
                break;
            }
            counter += 1;
        }
    }

    /**
     * Calculate the early exit penalty for selling x tokens and edit the timestamped ledger
     */
    function calculateAveragePenaltyAndUpdateLedger(
        uint256 _amountOfTokens,
        address _customerAddress
    ) internal onlyBagholders() returns (uint256) {
        // Parse through the list of transactions
        uint256 tokensFound = 0;
        Cursor storage _customerCursor =
            tokenTimestampedBalanceCursor[_customerAddress];
        uint256 counter = _customerCursor.start;
        uint256 averagePenalty = 0;

        while (counter <= _customerCursor.end) {
            TimestampedBalance storage transaction =
                tokenTimestampedBalanceLedger_[_customerAddress][counter];
            uint256 tokensAvailable =
                SafeMath.sub(transaction.value, transaction.valueSold);

            uint256 tokensRequired = SafeMath.sub(_amountOfTokens, tokensFound);

            if (tokensAvailable < tokensRequired) {
                tokensFound += tokensAvailable;
                averagePenalty = SafeMath.add(
                    averagePenalty,
                    SafeMath.mul(
                        _calculatePenalty(transaction.timestamp),
                        tokensAvailable
                    )
                );
                delete tokenTimestampedBalanceLedger_[_customerAddress][
                    counter
                ];
            } else if (tokensAvailable <= tokensRequired) {
                averagePenalty = SafeMath.add(
                    averagePenalty,
                    SafeMath.mul(
                        _calculatePenalty(transaction.timestamp),
                        tokensRequired
                    )
                );
                delete tokenTimestampedBalanceLedger_[_customerAddress][
                    counter
                ];
                _customerCursor.start = counter + 1;
                break;
            } else {
                averagePenalty = SafeMath.add(
                    averagePenalty,
                    SafeMath.mul(
                        _calculatePenalty(transaction.timestamp),
                        tokensRequired
                    )
                );
                transaction.valueSold += tokensRequired;
                _customerCursor.start = counter;
                break;
            }

            counter += 1;
        }

        return SafeMath.div(averagePenalty, _amountOfTokens);
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    /**
     * @dev calculates x*y and outputs a emulated 512bit number as l being the lower 256bit half and h the upper 256bit half.
     */
    function fullMul(uint256 x, uint256 y)
        public
        pure
        returns (uint256 l, uint256 h)
    {
        uint256 mm = mulmod(x, y, uint256(-1));
        l = x * y;
        h = mm - l;
        if (mm < l) h -= 1;
    }

    /**
     * @dev calculates x*y/z taking care of phantom overflows.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 z
    ) public pure returns (uint256) {
        (uint256 l, uint256 h) = fullMul(x, y);
        require(h < z);
        uint256 mm = mulmod(x, y, z);
        if (mm > l) h -= 1;
        l -= mm;
        uint256 pow2 = z & -z;
        z /= pow2;
        l /= pow2;
        l += h * ((-pow2) / pow2 + 1);
        uint256 r = 1;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        return l * r;
    }

    /*
     * =========================
     * Auto Reinvestment Feature
     * =========================
     */

    // uint256 recommendedRewardPerInvocation = 5000000; // 5 TRX

    struct AutoReinvestEntry {
        uint256 nextExecutionTime;
        uint256 rewardPerInvocation;
        uint256 minimumDividendValue;
        uint24 period;
    }

    mapping(address => AutoReinvestEntry) internal autoReinvestment;

    function setupAutoReinvest(
        uint24 period,
        uint256 rewardPerInvocation,
        uint256 minimumDividendValue
    ) public {
        _setupAutoReinvest(
            period,
            rewardPerInvocation,
            msg.sender,
            minimumDividendValue
        );
    }

    function _setupAutoReinvest(
        uint24 period,
        uint256 rewardPerInvocation,
        address customerAddress,
        uint256 minimumDividendValue
    ) internal {
        autoReinvestment[customerAddress] = AutoReinvestEntry(
            block.timestamp + period,
            rewardPerInvocation,
            minimumDividendValue,
            period
        );

        // Launch an event that this entry has been created
        emit onAutoReinvestmentEntry(
            customerAddress,
            autoReinvestment[customerAddress].nextExecutionTime,
            rewardPerInvocation,
            period,
            minimumDividendValue
        );
    }

    // Anyone can call this function and claim the reward
    function invokeAutoReinvest(address _customerAddress)
        external
        returns (uint256)
    {
        AutoReinvestEntry storage entry = autoReinvestment[_customerAddress];

        if (
            entry.nextExecutionTime > 0 &&
            block.timestamp >= entry.nextExecutionTime
        ) {
            // fetch dividends
            uint256 _dividends =
                dividendsOf(_customerAddress);

            // Only execute if the user's dividends are more that the
            // rewardPerInvocation and the minimumDividendValue
            if (
                _dividends > entry.minimumDividendValue &&
                _dividends > entry.rewardPerInvocation
            ) {
                // Deduct the reward from the users dividends
                payoutsTo_[_customerAddress] += (int256)(
                    entry.rewardPerInvocation * magnitude
                );

                // Update the Auto Reinvestment entry
                entry.nextExecutionTime +=
                    (((block.timestamp - entry.nextExecutionTime) /
                        uint256(entry.period)) + 1) *
                    uint256(entry.period);

                /*
                 * Do the reinvestment
                 */
                _reinvest(_customerAddress);

                // Send the caller their reward
                msg.sender.transfer(entry.rewardPerInvocation);
            }
        }

        return entry.nextExecutionTime;
    }

    // Read function for the frontend to determine if the user has setup Auto Reinvestment or not
    function getAutoReinvestEntry()
        public
        view
        returns (
            uint256,
            uint256,
            uint24,
            uint256
        )
    {
        address _customerAddress = msg.sender;
        AutoReinvestEntry storage _autoReinvestEntry =
            autoReinvestment[_customerAddress];
        return (
            _autoReinvestEntry.nextExecutionTime,
            _autoReinvestEntry.rewardPerInvocation,
            _autoReinvestEntry.period,
            _autoReinvestEntry.minimumDividendValue
        );
    }

    // Read function for the scheduling workers determine if the user has setup Auto Reinvestment or not
    function getAutoReinvestEntryOf(address _customerAddress)
        public
        view
        returns (
            uint256,
            uint256,
            uint24,
            uint256
        )
    {
        AutoReinvestEntry storage _autoReinvestEntry =
            autoReinvestment[_customerAddress];
        return (
            _autoReinvestEntry.nextExecutionTime,
            _autoReinvestEntry.rewardPerInvocation,
            _autoReinvestEntry.period,
            _autoReinvestEntry.minimumDividendValue
        );
    }

    // The user can stop the autoReinvestment whenever they want
    function stopAutoReinvest() external {
        address customerAddress = msg.sender;
        if (autoReinvestment[customerAddress].nextExecutionTime > 0) {
            delete autoReinvestment[customerAddress];

            // Launch an event that this entry has been deleted
            emit onAutoReinvestmentStop(customerAddress);
        }
    }

    // Allowance, Approval and Transfer From

    mapping(address => mapping(address => uint256)) private _allowances;

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        uint256 final_amount =
            SafeMath.sub(_allowances[sender][msg.sender], amount);

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, final_amount);
        return true;
    }

    function transfer(address _toAddress, uint256 _amountOfTokens)
        public
        onlyBagholders
        returns (bool)
    {
        _transfer(msg.sender, _toAddress, _amountOfTokens);
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient` after liquifying 10% of the tokens `amount` as dividens.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `_customerAddress` cannot be the zero address.
     * - `_toAddress` cannot be the zero address.
     * - `_customerAddress` must have a balance of at least `_amountOfTokens`.
     */
    function _transfer(
        address _customerAddress,
        address _toAddress,
        uint256 _amountOfTokens
    ) internal {
        require(
            _customerAddress != address(0),
            "TRC20: transfer from the zero address"
        );
        require(
            _toAddress != address(0),
            "TRC20: transfer to the zero address"
        );

        // make sure we have the requested tokens
        require(
            _amountOfTokens <= tokenBalanceLedger_[_customerAddress]
        );

        // withdraw all outstanding dividends first
        if (
            dividendsOf(_customerAddress) + referralBalance_[_customerAddress] >
            0
        ) {
            _withdraw(_customerAddress);
        }

        // updating tokenTimestampedBalanceLedger_ for _customerAddress
        _updateLedgerForTransfer(_amountOfTokens, _customerAddress);

        // liquify 10% of the remaining tokens that are transfered
        // these are dispersed to shareholders
        uint256 _tokenFee = SafeMath.div(_amountOfTokens, dividendFee_);

        uint256 _taxedTokens = SafeMath.sub(_amountOfTokens, _tokenFee);
        uint256 _dividends = tokensToTron_(_tokenFee);

        // burn the fee tokens
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokenFee);

        // exchange tokens
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(
            tokenBalanceLedger_[_customerAddress],
            _amountOfTokens
        );
        tokenBalanceLedger_[_toAddress] = SafeMath.add(
            tokenBalanceLedger_[_toAddress],
            _taxedTokens
        );

        // updating tokenTimestampedBalanceLedger_ for _toAddress
        tokenTimestampedBalanceLedger_[_toAddress].push(
            TimestampedBalance(_taxedTokens, block.timestamp, 0)
        );
        tokenTimestampedBalanceCursor[_toAddress].end += 1;

        // update dividend trackers
        payoutsTo_[_customerAddress] -= (int256)(
            profitPerShare_ * _amountOfTokens
        );
        payoutsTo_[_toAddress] += (int256)(profitPerShare_ * _taxedTokens);

        // disperse dividends among holders
        profitPerShare_ = SafeMath.add(
            profitPerShare_,
            mulDiv(_dividends, magnitude, tokenSupply_)
        );

        // fire event
        emit Transfer(_customerAddress, _toAddress, _taxedTokens);
    }

    // Atomically increases the allowance granted to `spender` by the caller.

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        uint256 final_allowance =
            SafeMath.add(_allowances[msg.sender][spender], addedValue);

        _approve(msg.sender, spender, final_allowance);
        return true;
    }

    //Atomically decreases the allowance granted to `spender` by the caller.
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        uint256 final_allowance =
            SafeMath.sub(_allowances[msg.sender][spender], subtractedValue);

        _approve(msg.sender, spender, final_allowance);
        return true;
    }

    // Sets `amount` as the allowance of `spender` over the `owner`s tokens.
    function _approve(
        address owner,
        address spender,
        uint256 value
    ) internal {
        require(owner != address(0), "TRC20: approve from the zero address");
        require(spender != address(0), "TRC20: approve to the zero address");
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
     * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
