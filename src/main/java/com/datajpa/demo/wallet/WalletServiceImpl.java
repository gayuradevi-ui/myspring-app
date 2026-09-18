package com.datajpa.demo.wallet;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
public class WalletServiceImpl implements WalletService {
    @Autowired
    private WalletRepository walletRepository;

    @Override
    public Wallet registerNewWalletUser(Wallet newWallet) {
        newWallet.setCreatedAt(LocalDateTime.now());
        return this.walletRepository.save(newWallet);
    }

    @Override
    public Wallet getUserWalletById(Integer walletID) {
        Optional<Wallet> foundWallet = this.walletRepository.findById(walletID);
        if (foundWallet.isPresent()) {
            return foundWallet.get();
        }
        return null;
    }

    @Override
    public Wallet updateUserWallet(Wallet updateWallet) {
        return null;
    }

    @Override
    public Double addFundsToWalletByID(Integer ID, Double balance) {
        return 0.0;
    }

    @Override
    public Double withdrawFundsToWalletByID(Integer ID, Double amount) {
        return 0.0;
    }

    @Override
    public Boolean fundTransfer(Integer fromID, Integer toID, Double amount) {
        return null;
    }

    @Override
    public Boolean deactivateWalletByID(Integer ID) {
        return null;
    }

    @Override
    public Boolean activateWalletByID(Integer ID) {
        return null;
    }
}
