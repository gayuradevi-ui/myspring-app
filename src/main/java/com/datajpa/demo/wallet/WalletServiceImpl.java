package com.datajpa.demo.wallet;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
public class WalletServiceImpl implements WalletService {
    private static final Logger logger = LoggerFactory.getLogger(WalletServiceImpl.class);
    
    @Autowired
    private WalletRepository walletRepository;

    @Override
    public Wallet registerNewWalletUser(Wallet newWallet) {
        try {
            if (newWallet == null) {
                throw new IllegalArgumentException("Wallet object cannot be null");
            }
            newWallet.setCreatedAt(LocalDateTime.now());
            if (newWallet.getIsActive() == null) {
                newWallet.setIsActive(true);
            }
            logger.info("Registering new wallet user: {}", newWallet.getName());
            Wallet savedWallet = this.walletRepository.save(newWallet);
            logger.info("Successfully registered wallet with ID: {}", savedWallet.getId());
            return savedWallet;
        } catch (Exception e) {
            logger.error("Error registering wallet user", e);
            throw new RuntimeException("Error registering wallet: " + e.getMessage(), e);
        }
    }

    @Override
    public Wallet getUserWalletById(Integer walletID) {
        try {
            if (walletID == null || walletID <= 0) {
                throw new IllegalArgumentException("Invalid wallet ID");
            }
            Optional<Wallet> foundWallet = this.walletRepository.findById(walletID);
            if (foundWallet.isPresent()) {
                logger.info("Found wallet with ID: {}", walletID);
                return foundWallet.get();
            }
            logger.warn("Wallet not found with ID: {}", walletID);
            return null;
        } catch (Exception e) {
            logger.error("Error retrieving wallet", e);
            throw new RuntimeException("Error retrieving wallet: " + e.getMessage(), e);
        }
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
