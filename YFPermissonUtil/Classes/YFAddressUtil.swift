//
//  YFAddressUtil.swift
//  YFPermissonUtil_Example
//
//  Created by Computer  on 12/01/26.
//  Copyright © 2026 CocoaPods. All rights reserved.
//
import Contacts
import AddressBook
import UIKit

@objc public class YFAddressUtil: NSObject {
    
    @objc public func requestAddressPermission(isRequired: Bool, completion: @escaping (Bool, Int, Bool) -> Void) {
         let currentStatus = CNContactStore.authorizationStatus(for: .contacts)
         switch currentStatus {
         case .notDetermined:
             let store = CNContactStore()
             store.requestAccess(for: .contacts) { granted, error in
                 DispatchQueue.main.async {
                     if granted {
                         let newStatus = CNContactStore.authorizationStatus(for: .contacts)
                         if #available(iOS 18.0, *) {
                             if newStatus == .limited {
                                 if isRequired {
                                     completion(false, newStatus.rawValue, false)
                                 } else {
                                     
                                     completion(true, newStatus.rawValue, false)
                                 }
                                 return
                             }
                         }
                        
                         
                         completion(true, newStatus.rawValue, false)
                     } else {
                        
                         
                         let deniedStatus = CNContactStore.authorizationStatus(for: .contacts)
                         if isRequired {
                             
                             completion(false, deniedStatus.rawValue, false)
                         } else {
                             
                             completion(true, deniedStatus.rawValue, false)
                         }
                     }
                 }
             }
         case .authorized:
             completion(true, currentStatus.rawValue, false)
         case .denied, .restricted:
             
             if isRequired {
                 
                 completion(false, currentStatus.rawValue, true)
             } else {
                 
                 completion(true, currentStatus.rawValue, false)
             }
         case .limited:
            
             
             if isRequired {
                 
                 completion(false, currentStatus.rawValue, true)
             } else {
                 
                 completion(true, currentStatus.rawValue, false)
             }
         @unknown default:
             
             if isRequired {
                 completion(false, currentStatus.rawValue, true)
             } else {
                 completion(true, currentStatus.rawValue, false)
             }
         }
     }
    
    
    @objc public func getContactsGroups(maxCount: Int, perCount: Int) -> [[[String: Any]]] {
        
        let allContacts = fetchAllContacts()
        
        
        let limitedContacts = limitContactsCount(allContacts, maxCount: maxCount)
        
        
        let groupedContacts = splitContactsIntoGroups(limitedContacts, perCount: perCount)
        return groupedContacts
    }
    
    
    private func fetchAllContacts() -> [[String: Any]] {
        
        let rawContacts = fetchRawAddressBookData()
        
        
        let formattedContacts = formatAndDeduplicateContacts(rawContacts)
        
        return formattedContacts
    }
    
    
    private func formatAndDeduplicateContacts(_ rawContacts: [[String: Any]]) -> [[String: Any]] {
        var formattedContacts: [[String: Any]] = []
        var uniquePhoneNumbers: Set<String> = []
        
        for rawContact in rawContacts {
            
            let updateTime = extractUpdateTime(from: rawContact)
            let displayName = buildContactName(from: rawContact)
            let phoneNumbers = rawContact["phoneNumbers"] as? [String] ?? []
            
            
            
            for phone in phoneNumbers {
                
                guard let validPhone = validateAndFormatPhone(phone) else { continue }
                
                
                
                if uniquePhoneNumbers.contains(validPhone) { continue }
                uniquePhoneNumbers.insert(validPhone)
                
                
                
                let contact = buildContactDictionary(
                    name: displayName,
                    phone: validPhone,
                    updateTime: updateTime
                )
                
                
                formattedContacts.append(contact)
            }
        }
                
                return formattedContacts
    }
    
    private func fetchRawAddressBookData() -> [[String: Any]] {
        
        guard checkContactsPermission() else { return [] }
        
        guard let addressBook = createAddressBook() else { return [] }
        
        guard let allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook)?.takeRetainedValue() as? [ABRecord] else {
            return []
        }
        
        let rawContacts = parseAddressBookPeople(allPeople)
        return rawContacts
    }
    
    
    private func checkContactsPermission() -> Bool {
        let authStatus = CNContactStore.authorizationStatus(for: .contacts)
        if #available(iOS 18.0, *) {
            return authStatus == .limited || authStatus == .authorized
        } else {
            return authStatus == .authorized
        }
    }
    
    private func createAddressBook() -> ABAddressBook? {
        var error: Unmanaged<CFError>?
        guard let addressBook = ABAddressBookCreateWithOptions(nil, &error)?.takeRetainedValue(),
              error == nil else {
            return nil
        }
        return addressBook
    }
    
    private func parseAddressBookPeople(_ people: [ABRecord]) -> [[String: Any]] {
        var rawContacts: [[String: Any]] = []
        for person in people {
            let contact = parseSinglePerson(person)
            rawContacts.append(contact)
        }
        return rawContacts
    }
    
    private func parseSinglePerson(_ person: ABRecord) -> [String: Any] {
        var contact: [String: Any] = [:]
        
        let firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty)?
            .takeRetainedValue() as? String ?? ""
        let lastName = ABRecordCopyValue(person, kABPersonLastNameProperty)?
            .takeRetainedValue() as? String ?? ""
        contact["firstName"] = firstName
        contact["lastName"] = lastName
        
        contact["phoneNumbers"] = extractPhoneNumbers(from: person)
        
        contact["createDate"] = ABRecordCopyValue(person, kABPersonCreationDateProperty)?
            .takeRetainedValue() as? NSDate
        contact["modifyDate"] = ABRecordCopyValue(person, kABPersonModificationDateProperty)?
            .takeRetainedValue() as? NSDate
        return contact
    }
    
    
    private func extractPhoneNumbers(from person: ABRecord) -> [String] {
        var phoneNumbers: [String] = []
        guard let multiValue = ABRecordCopyValue(person, kABPersonPhoneProperty)?
            .takeRetainedValue() as? ABMultiValue else {
            return phoneNumbers
        }
        for i in 0..<ABMultiValueGetCount(multiValue) {
            if let phoneValue = ABMultiValueCopyValueAtIndex(multiValue, i)?
                .takeRetainedValue() as? String,
               !phoneValue.isEmpty {
                phoneNumbers.append(phoneValue)
            }
        }
        return phoneNumbers
    }
    
    private func extractUpdateTime(from contact: [String: Any]) -> String {
        guard let modifyDate = contact["modifyDate"] as? NSDate else {
            return ""
        }
        let timestamp = Int(modifyDate.timeIntervalSince1970 * 1000)
        return "\(timestamp)"
    }
    
    private func buildContactName(from contact: [String: Any]) -> String {
        let lastName = contact["lastName"] as? String ?? ""
        let firstName = contact["firstName"] as? String ?? ""
        let displayName = "\(lastName) \(firstName)".trimmingCharacters(in: .whitespaces)
        return displayName
    }
    
    
    private func validateAndFormatPhone(_ phone: String) -> String? {
        
        let normalizedPhone = normalizePhone(phone)
        
        guard isValidPhoneNumber(normalizedPhone) else { return nil }
        
        let formattedPhone = formatPhoneTo10Digits(normalizedPhone)
        return formattedPhone
    }
    
    private func normalizePhone(_ phone: String) -> String {
        let digits = CharacterSet.decimalDigits.inverted
        return phone.components(separatedBy: digits).joined()
    }
    
    private func isValidPhoneNumber(_ phone: String) -> Bool {
        let phoneRegex = "^(91[6-9]\\d{9}|910[6-9]\\d{9}|[6-9]\\d{9}|0[6-9]\\d{9})$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return predicate.evaluate(with: phone)
    }
    
    private func formatPhoneTo10Digits(_ phone: String) -> String {
        
        if phone.count == 13 && phone.hasPrefix("910") {
            return String(phone.suffix(10))
        }
        
        if phone.count == 12 && phone.hasPrefix("91") {
            return String(phone.suffix(10))
        }
        
        if phone.count == 11 && phone.hasPrefix("0") {
            return String(phone.suffix(10))
        }
        
        return phone
    }
    
    
    private func buildContactDictionary(name: String, phone: String, updateTime: String) -> [String: Any] {
        return [
            "contactName": name,
            "contactPhone": phone,
            "contactUpdateTime": updateTime,
            "contactCount": "99",
            "contactTime": "",
            "contactStorage": "1"
        ]
    }
    
    
    private func limitContactsCount(_ contacts: [[String: Any]], maxCount: Int) -> [[String: Any]] {
        if contacts.count > maxCount {
            return Array(contacts.prefix(maxCount))
        }
        return contacts
    }
    
    
    private func splitContactsIntoGroups(_ contacts: [[String: Any]], perCount: Int) -> [[[String: Any]]] {
        var groups: [[[String: Any]]] = []
        var startIndex = 0
        while startIndex < contacts.count {
            let endIndex = min(startIndex + perCount, contacts.count)
            let group = Array(contacts[startIndex..<endIndex])
            groups.append(group)
            startIndex = endIndex
        }
        return groups
    }
}
