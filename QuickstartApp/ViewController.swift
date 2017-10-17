import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

class ViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate, UITextViewDelegate {
    //MARK: Properties
    
    var write = ""
    var listOfTextFields: [String] = []
    var overallRowNumArray: [String] = []
    var frameView: UIView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheets]
    
    private let service = GTLRSheetsService()
    let signInButton = GIDSignInButton()
    let output = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        
        // Add the sign-in button.
        view.addSubview(signInButton)
        
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(ViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(ViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.signInButton.isHidden = true
            self.output.isHidden = false
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat="dd/MM/yyyy"
            let dateResult = formatter.string(from: date)
            dateLabel.text = dateResult
            dateLabel.isHidden = true
            updateButton.isHidden = true
            listMajors()
        }
    }
    
    
    // Display (in the UITextView) the names and majors of students in a sample
    // spreadsheet:
    // https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit
    func listMajors() {
        //displayLabel.text = "Getting sheet data..."
        write = "no"
        let spreadsheetId = "1L2p4KPnvze1-vJXeOIRAxT19haalvp106Px9VuiG5dI"
        let range = "Test!A2:g"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: spreadsheetId, range:range)
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:))
        )
    }
    
    // Process the GET response and display output
    @objc func displayResultWithTicket(ticket: GTLRServiceTicket,
                                 finishedWithObject result : GTLRSheets_ValueRange,
                                 error : NSError?) {
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
                
        let rows = result.values!
        
        if rows.isEmpty {
            //displayLabel.text = "No data found."
            return
        }
        
        for row in rows {
            
            let workoutDate = String(describing: row[2])
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat="dd/MM/yyyy"
            let dateResult = formatter.string(from: date)

            if dateResult == workoutDate {
            let rowNum = String(describing: row[1])
            let overallRowNum = String(describing: row[0])
            let lift = row[3]
            let weight = row[4]
            let reps = row[5]
            let speed = row[6]
            
            let yvalue = CGFloat(Float(Int(rowNum)!*25+80))
            
            overallRowNumArray.append(overallRowNum)
                
            let liftlabel = UILabel(frame: CGRect(x: 0, y: 100, width: 200, height: 21))
                liftlabel.center = CGPoint(x: 130, y: yvalue)
                liftlabel.textAlignment = .left
                liftlabel.text = String(describing: lift)
            self.view.addSubview(liftlabel)
        
            let weightlabel = UILabel(frame: CGRect(x: 0, y: 100, width: 200, height: 21))
                weightlabel.center = CGPoint(x: 200, y: yvalue)
                weightlabel.textAlignment = .left
                weightlabel.text = String(describing: weight)
            self.view.addSubview(weightlabel)
            
            let repslabel = UILabel(frame: CGRect(x: 0, y: 100, width: 200, height: 21))
                repslabel.center = CGPoint(x: 245, y: yvalue)
                repslabel.textAlignment = .left
                repslabel.text = String(describing: reps)
            self.view.addSubview(repslabel)
            
            let speedlabel = UITextField(frame: CGRect(x: 0, y: 100, width: 200, height: 21))
                speedlabel.center = CGPoint(x: 265, y: yvalue)
                speedlabel.textAlignment = .left
                speedlabel.text = String(describing: speed)
                speedlabel.font = speedlabel.font?.withSize(14)
                speedlabel.tag = Int(rowNum)!-1
                listOfTextFields.append(speedlabel.text!)
                speedlabel.keyboardType = .decimalPad
            self.view.addSubview(speedlabel)
            }
        }
        dateLabel.isHidden = false
        updateButton.isHidden = false
    }
    
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func writeData() {
        let tags = [0,1,2,3,4,5,6,7,8,9,10,11,12]
        for tag in tags {
            for subview in view.subviews {
                if subview is UITextField && subview.tag == tag {
                    let speed0label = subview as! UITextField
                    listOfTextFields[tag] = speed0label.text!
                }
            }
            let spreadsheetId = "1L2p4KPnvze1-vJXeOIRAxT19haalvp106Px9VuiG5dI"
            let range = "\("Test!g" + overallRowNumArray[tag] + ":g" + overallRowNumArray[tag])"
            //print(range)
            let valueRange = GTLRSheets_ValueRange.init()
            //print(listOfTextFields[0])
            valueRange.values = [[listOfTextFields[tag] as Any]]
            let query = GTLRSheetsQuery_SpreadsheetsValuesUpdate
                .query(withObject: valueRange, spreadsheetId: spreadsheetId, range: range)
                query.valueInputOption = "USER_ENTERED"
            service.executeQuery(query,
                                 delegate: self,
                                 didFinish: #selector(ViewController.displayResultWithTicketSubmit(ticket:finishedWithObject:error:))
            )
        }
    }
    
    @IBAction func Refresh(_ sender: Any) {

        writeData()
        for subview in view.subviews {
            if subview is UITextField && subview.tag != 9999 {
                subview.removeFromSuperview()
            }
        }
        self.view.endEditing(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25){
                self.listMajors()
            }
        }
    
    //Submit Process Response
    @objc func displayResultWithTicketSubmit(ticket: GTLRServiceTicket,
                                        finishedWithObject result : GTLRSheets_ValueRange,
                                        error : NSError?) {
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let info:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardHeight: CGFloat = keyboardSize.height-keyboardSize.height
        
        let _: CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber as! CGFloat
        
        
        UIView.animate(withDuration: 0.25, delay: 0.25, options: .curveEaseInOut, animations: {
            self.view.frame = CGRect(x: 0, y: (self.view.frame.origin.y - keyboardHeight), width: self.view.bounds.width, height: self.view.bounds.height)
        }, completion: nil)
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let info: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardHeight: CGFloat = keyboardSize.height
        
        let _: CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber as! CGFloat
        
        UIView.animate(withDuration: 0.25, delay: 0.25, options: .curveEaseInOut, animations: {
            
            self.view.frame = CGRect(x: 0, y: (self.view.frame.origin.y + keyboardHeight-keyboardHeight), width: self.view.bounds.width, height: self.view.bounds.height)
        }, completion: nil)
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
}
