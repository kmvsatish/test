//
//  ConditionaAndSymptomsViewController.swift
//  DigiClinic
//
//  Created by Shyamchandar on 30/01/17.
//  Copyright © 2017 chandramouli. All rights reserved.
//

import UIKit

class ConditionaAndSymptomsViewController: UIViewController,conditonsDelegate,UITableViewDelegate,UITableViewDataSource,NetworkManagerDelegate,sortDelegate {

    @IBOutlet var conditionsTableView:UITableView?
    var deletedConditionModel:ConditionsAndSymptomsModel = ConditionsAndSymptomsModel()
    var sortView:MyHealthSortView = MyHealthSortView.instanceFromNib() as! MyHealthSortView
    var conditionsArray:NSMutableArray = NSMutableArray()
    var dateSort:Bool = false
    var nameSort:Bool = false
    var isFirstTime:Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        /*let conditionsModel = ConditionsAndSymptomsModel()
        conditionsModel.conditionOrSymptom = "Postprocedure process"
        conditionsModel.isCurrent = true
        conditionsModel.detail = "Postprocedural process"
        conditionsModel.entryDate = "31/01/2017"
        self.conditionsArray.add(conditionsModel)
        
        let conditionsModel1 = ConditionsAndSymptomsModel()
        conditionsModel1.conditionOrSymptom = "Postprocedural hematoma of ear and mastoid process following a procedure on the ear and mastoid process Postprocedural hematoma of ear and mastoid process following a procedure on the ear and mastoid process"
        conditionsModel1.isCurrent = true
        conditionsModel1.detail = "Postprocedural hematoma of ear and mastoid process following a procedure on the ear and mastoid process Postprocedural hematoma of ear and mastoid process following a procedure on the ear and mastoid process"
        conditionsModel1.entryDate = "31/01/2017"

        self.conditionsArray.add(conditionsModel1)*/
        
//        self.conditionsTableView?.rowHeight = UITableViewAutomaticDimension
//        self.conditionsTableView?.estimatedRowHeight = 100
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
//        if self.conditionsArray.count > 0
//        {
//            self.conditionsTableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
//        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.contentChanged(notfication:)),
            name:  NSNotification.Name.UIContentSizeCategoryDidChange,
            object: nil)
        if  conditionsArray.count == 0 {
            LoadingView.shareInstance.showLodingView(parentView: self.view.window!)
        }
        
        
        NetwrokManager.sharedInstance().addBackgroundTask(with: .getPatientConditions, delegate: self)
        
    }

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func contentChanged(notfication:NSNotification) {
        self.conditionsTableView?.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addButtonAction()  {
        NavigationModel.sharedInstance.navigateToAddConditionWithModel(dataModel: nil)
    }
    @IBAction func backAction(_ sender: Any) {
        NetwrokManager.sharedInstance().invalidateCurrentSession()
       NavigationModel.sharedInstance.goBackInMainNavigationController()
    }
    
    @IBAction func sortAction(_ sender: Any) {
        self.sortView.showSortView(delegate: self, parentView: self.view)
//        let alert:UIAlertController = UIAlertController(title: "Sort", message: "Please choose sort order", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Sort By Date", style: .default, handler:{ (ACTION :UIAlertAction!)in
//            let sortKey:NSSortDescriptor = NSSortDescriptor(key: "dataEntryDate", ascending: true)
//            self.conditionsArray = NSMutableArray(array: self.conditionsArray.sortedArray(using: [sortKey]))
//            self.conditionsTableView?.reloadData()
//        }))
//        alert.addAction(UIAlertAction(title: "Sort By Name", style: .default, handler:{ (ACTION :UIAlertAction!)in
//            let sortKey:NSSortDescriptor = NSSortDescriptor(key: "conditionOrSymptom", ascending: true, selector:#selector(NSString.caseInsensitiveCompare(_:)))
//            self.conditionsArray = NSMutableArray(array: self.conditionsArray.sortedArray(using: [sortKey]))
//            self.conditionsTableView?.reloadData()
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (ACTION :UIAlertAction!)in
//            
//        }))
//        self.present(alert, animated: true, completion: nil)
    }
    // MARK: - sort delegate
    func showOrderedByName() {
        nameSort = !nameSort
        
        let sortKey:NSSortDescriptor = NSSortDescriptor(key: "conditionOrSymptom", ascending: nameSort, selector:#selector(NSString.caseInsensitiveCompare(_:)))
        self.conditionsArray = NSMutableArray(array: self.conditionsArray.sortedArray(using: [sortKey]))
        self.conditionsTableView?.reloadData()
    }
    
    func showOrderedByDate() {
        dateSort = !dateSort
        let sortKey:NSSortDescriptor = NSSortDescriptor(key: "dataEntryDate", ascending: dateSort)
        self.conditionsArray = NSMutableArray(array: self.conditionsArray.sortedArray(using: [sortKey]))
        self.conditionsTableView?.reloadData()
    }
    
    // MARK: - Conditions delegate
    func editButtonAction(dataModel: Any) {
        self.conditionsTableView?.scrollsToTop = true
        
        NavigationModel.sharedInstance.navigateToAddConditionWithModel(dataModel: dataModel as? ConditionsAndSymptomsModel)
    }
    
    func removeButtonAction(dataModel: Any) {
        SharedObjectModel.sharedInstance.selectedConditionID = (dataModel as! ConditionsAndSymptomsModel).Id
//        SharedObjectModel.sharedInstance.selectedConditionID = "1" //TODO: Remove this line, its added for Testing 
        self.deletedConditionModel = dataModel as! ConditionsAndSymptomsModel
        LoadingView.shareInstance.showLodingView(parentView: self.view.window!)
        present(Helper.deleteConfirmation(ServiceRequestType.deleteConditions, self), animated: true, completion: nil)
    }
    
    // MARK: - Table view delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.conditionsArray.count)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == self.conditionsArray.count {
            let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "AddCell")!
            let addButton:UIButton = cell.contentView.viewWithTag(100) as! UIButton
            addButton.layer.borderWidth = 1.0
            addButton.layer.borderColor = addButton.titleColor(for: .normal)?.cgColor
            addButton.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
            return cell
        }
        else
        {
            let cell:ConditionsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ConditionsCell") as! ConditionsTableViewCell
            let rowData:ConditionsAndSymptomsModel = self.conditionsArray.object(at: indexPath.row) as! ConditionsAndSymptomsModel
            cell.conditionsModel = rowData
            cell.delegate = self
            cell.selectionStyle = .none

            cell.setCell()
            return cell
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.setNeedsUpdateConstraints()
        cell.layoutIfNeeded()
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    @IBAction func addNewCondition(_ sender: Any) {
        self.addButtonAction()
    }
    func response(for requestType: ServiceRequestType, isSuccess: Bool, responseData Data: Any!, withStatusCode statusCode: Int, errorMessage message: Any!) {
        //print("statusCode:\(statusCode)")
        if statusCode == 200 || statusCode == 204 { //TODO: Change to proper Status code check
            
            if requestType == .getPatientConditions  {
               LoadingView.shareInstance.hideLoadingView()
                if (Data != nil)  {
               conditionsArray = ResponseParser.sharedInstance.getPatientConditionResponse(requestType: requestType, dataArray: Data as! NSArray)
                }
                if isFirstTime
                {
                   isFirstTime = false
                    if conditionsArray.count == 0
                    {
                        addButtonAction()
                    }
                }
                let currentSortKey:NSSortDescriptor = NSSortDescriptor(key: "isCurrent", ascending: false)
                let dateSortKey:NSSortDescriptor = NSSortDescriptor(key: "dataEntryDate", ascending: false)
                conditionsArray.sort(using: [currentSortKey,dateSortKey])
                self.conditionsTableView?.reloadData()
                
//                self.conditionsTableView?.reloadData()
            }
            else if requestType == .deleteConditions
            {
                LoadingView.shareInstance.hideLoadingView()
                if isSuccess {
                    conditionsArray.remove(deletedConditionModel)
                    AlertView.showAlertMessageOption("Conditions or Symptoms deleted successfully")
                    
                    self.conditionsTableView?.reloadData()
                    if let landiControler:LandingPageViewController = NavigationModel.sharedInstance.mainNavigationController?.viewControllers[0] as? LandingPageViewController
                    {
                        NetwrokManager.sharedInstance().addBackgroundTask(with: .getMyHealthCards, delegate: landiControler.myHealthController!)
                    }
                
                }
                
                LoadingView.shareInstance.showLodingView(parentView: self.view.window!)
                
                NetwrokManager.sharedInstance().addBackgroundTask(with: .getPatientConditions, delegate: self)
                
            }
        }
        else {
            LoadingView.shareInstance.hideLoadingView()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
