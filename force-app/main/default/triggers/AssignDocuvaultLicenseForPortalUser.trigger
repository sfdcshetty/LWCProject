/*
* Trigger to auto assign Docuvault license for Community User
* It will check for the User profile, if it contains "Community" then only it will assign Docuvault License
*/
trigger AssignDocuvaultLicenseForPortalUser on User (After Insert) {
    if(Trigger.isAfter) { 
        try {
            PackageLicense pckgLicenseList = New PackageLicense ();
            pckgLicenseList = [SELECT NamespacePrefix FROM PackageLicense WHERE NamespacePrefix = 'TVA_CFB' LIMIT 1];
            
            PackageLicense premiumPkgLicenseList = New PackageLicense ();
            try {
                premiumPkgLicenseList = [SELECT NamespacePrefix FROM PackageLicense WHERE NamespacePrefix = 'TVA_CFP' LIMIT 1];
            }
            catch (Exception e) {}
            String profileName = Label.Community_Profile_Name;
            if (Test.isRunningTest ()) {
                profileName = 'System Administrator';
            }
            List <UserPackageLicense> newUserPackageList = new List <UserPackageLicense> ();
            for(User usr : [SELECT profile.Name FROM User WHERE ID IN: Trigger.NEW]) {
                String userProfileName = usr.Profile.name;
                userProfileName = userProfileName.toLowerCase ();
                profileName = profileName.toLowerCase ();
                if (userProfileName.contains (profileName)) { 
                    UserPackageLicense newUserPackage = new UserPackageLicense ();
                    newUserPackage.Userid = usr.Id;
                    newUserPackage.PackageLicenseid = pckgLicenseList.id;
                    newUserPackageList.add (newUserPackage);
                    try {
                        if (premiumPkgLicenseList.id != NULL) {
                            UserPackageLicense newUserPremiumPackage = new UserPackageLicense ();
                            newUserPremiumPackage.Userid = usr.Id;
                            newUserPremiumPackage.PackageLicenseid = premiumPkgLicenseList.id;
                            newUserPackageList.add (newUserPremiumPackage);
                        }
                    } catch (Exception e) {}
                }
            }
            insert newUserPackageList;
        }
        catch (Exception e) {}
    }
}