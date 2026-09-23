package com.datajpa.demo.wallet;

import jakarta.persistence.Entity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
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
    @ResponseStatus(HttpStatus.CREATED)
    public ResponseEntity<Wallet> registerNewWallet(@RequestBody Wallet newWallet){
        try {
            if (newWallet == null) {
                return ResponseEntity.badRequest().build();
            }
            Wallet savedWallet = this.walletService.registerNewWalletUser(newWallet);
            return ResponseEntity.status(HttpStatus.CREATED).body(savedWallet);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GetMapping("/{walletID}")
    public ResponseEntity<Wallet> getWalletByID(@RequestParam Integer walletID){
        try {
            Wallet wallet = this.walletService.getUserWalletById(walletID);
            if (wallet != null) {
                return ResponseEntity.ok(wallet);
            }
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }


}

