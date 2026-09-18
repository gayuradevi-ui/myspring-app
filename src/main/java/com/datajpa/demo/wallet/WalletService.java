package com.datajpa.demo.wallet;

public interface WalletService {

    Wallet registerNewWalletUser(Wallet newWallet);
    Wallet getUserWalletById(Integer walletId);
    Wallet updateUserWallet(Wallet updateWallet);

    Double addFundsToWalletByID(Integer ID,Double balance);
    Double withdrawFundsToWalletByID(Integer ID,Double amount);

    Boolean fundTransfer(Integer fromID,Integer toID, Double amount);
    Boolean deactivateWalletByID(Integer ID);
    Boolean activateWalletByID(Integer ID);

}
