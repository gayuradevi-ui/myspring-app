package com.datajpa.demo.wallet;

import jakarta.persistence.Entity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/wallet")
public class WalletController {
    @Autowired
    private WalletService walletService;
    @GetMapping
    public String hello(){
        return "hello";
    }
    //Register New Wallet User
    @PostMapping("/register")
    Wallet registerNewWallet(@RequestBody Wallet newWallet){
        return this.walletService.registerNewWalletUser(newWallet);

    }

    @GetMapping("/{walletID}")
    Wallet getWalletByID(@RequestParam Integer walletID){
        return this.walletService.getUserWalletById(walletID);
    }


}

