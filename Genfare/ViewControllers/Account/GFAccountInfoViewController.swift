//
//  GFAccountInfoViewController.swift
//  Genfare
//
//  Created by vishnu on 06/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GFAccountInfoViewController: GFBaseViewController,UITableViewDelegate,UITableViewDataSource,WalletProtocol,UITextFieldDelegate {

    let viewModel = GFAccountInfoViewModel()
    let disposeBag = DisposeBag()

    @IBOutlet weak var transferBtn: GFMenuButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createViewModelBinding()
        createCallbacks()
    }
    
    override func viewWillAppear( _ animated:Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .gray
        navigationController?.setNavigationBarHidden(false, animated: false);
        navigationController?.navigationBar.barTintColor = UIColor.topNavBarColor

        // Do any additional setup after loading the view.
    }
    
    func createViewModelBinding(){
        
        transferBtn.rx.tap.do(onNext:  { [unowned self] in
            print(self)
         
        }).subscribe(onNext: { [unowned self] in
            self.transferCard()
        }).disposed(by: disposeBag)
    }
  
    func createCallbacks (){
        // success
        viewModel.isSuccess.asObservable()
            .bind{ [unowned self] value in
                NSLog("Successfull \(value)")
                if value{
                    self.popupAlert(title: "Success", message: "Card Released", actionTitles: ["OK"], actions: [nil])
                    //self.dismiss(animated: true, completion: nil)
                }
            }.disposed(by: disposeBag)
        
        // Loading
        viewModel.isLoading.asObservable()
            .bind{[unowned self] value in
                if value {
                    self.attachSpinner(value: value)
                }
            }.disposed(by: disposeBag)
        
        // errors
        viewModel.errorMsg.asObservable()
            .bind {[unowned self] errorMessage in
                // Show error
                self.showErrorMessage(message: errorMessage)
            }.disposed(by: disposeBag)
        
        // Logout
        viewModel.logoutUser.asObservable()
            .bind{[unowned self] value in
                if value {
                    self.logoutUser()
                }
            }.disposed(by: disposeBag)
    }
    
    func transferCard() {
        let existingPassword = String(describing: KeychainWrapper.standard.string(forKey: Constants.KeyChain.Password)!)
        let email = (String(describing: KeychainWrapper.standard.string(forKey: Constants.KeyChain.UserName)!))
        let alert = UIAlertController(title: Utilities.colorHexString(resourceId:"retriveCreditCardAlertTitle"), message: (String(format:"Enter the password for %@ to use saved cards.\n\nOnce the password is verified, this card will be used for further Payment",email)), preferredStyle: UIAlertController.Style.alert)
        
        
        alert.addTextField { (textField) -> Void in
            let  passwordTextField = textField
            passwordTextField.delegate = self
            passwordTextField.placeholder = "Password"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "verify", style: UIAlertAction.Style.destructive, handler: { action in
            let passwordText = alert.textFields![0]
            if(passwordText.text == existingPassword){
                self.viewModel.getConfigValues()
            }else{
                let alert = UIAlertController(title: "Password", message: "Please provide correct password", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }))
         present(alert, animated: true, completion: nil)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userAccount:Account? = GFAccountManager.currentAccount()
         let wallet = self.userWallet()
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cardDetailsCell", for: indexPath) as? GFAccountManagementTableViewCell else { return UITableViewCell()}
        cell.unassignBtn.isHidden = true
        switch (indexPath.row) {
        case 0:
            cell.detailLbl.text = "Account Email"
            cell.unassignBtn.isHidden = false
            cell.unassignBtn.isUserInteractionEnabled = true
            cell.titleLbl.text = userAccount?.emailaddress
             break;
        case 1:
            cell.detailLbl.text = "Card Nickname"
            cell.titleLbl.text  =  "\(wallet!.nickname!) - \(wallet!.status!)"
         break;
        case 2:
            cell.detailLbl.text = "Card Type"
            cell.titleLbl.text  =  String(format: "%@ (%@)", (wallet?.cardType)!,userAccount!.profileType!)
        break;
        case 3:
            cell.detailLbl.text = "Bonus Accruals"
            cell.titleLbl.text  =  "NA"
            break;
        case 4:
           cell.detailLbl.text = "Capped Accruals"
           cell.titleLbl.text  =  "NA"
            break;
        default:
            break;
        }
        return cell
    }
}

