import Foundation
import UIKit

/// Hilfsklasse zum Erkennen von externen Speichergeräten auf iOS
class ExternalStorageDetector {
    
    /// Prüft, ob externe Speichergeräte verfügbar sind
    static func checkForExternalStorage() -> [URL] {
        var externalDrives: [URL] = []
        
        let fileManager = FileManager.default
        
        // Prüfe die verfügbaren Volume-URLs
        if let volumes = fileManager.mountedVolumeURLs(includingResourceValuesForKeys: [.volumeNameKey, .volumeIsRemovableKey], options: []) {
            for volume in volumes {
                // Prüfe, ob es sich um ein externes/entfernbares Laufwerk handelt
                if let resourceValues = try? volume.resourceValues(forKeys: [.volumeIsRemovableKey, .volumeNameKey]),
                   resourceValues.volumeIsRemovable == true {
                    externalDrives.append(volume)
                    print("✅ Externes Gerät gefunden: \(volume.lastPathComponent)")
                }
            }
        }
        
        // Prüfe auch über die document directory URLs
        // iOS zeigt externe Geräte manchmal unter verschiedenen Pfaden an
        if let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let documentsParent = documentsPath.deletingLastPathComponent()
            
            // Prüfe alle Verzeichnisse im gleichen Level wie Documents
            if let contents = try? fileManager.contentsOfDirectory(at: documentsParent, includingPropertiesForKeys: [.volumeNameKey, .volumeIsRemovableKey], options: []) {
                for url in contents {
                    if let resourceValues = try? url.resourceValues(forKeys: [.volumeIsRemovableKey]),
                       resourceValues.volumeIsRemovable == true,
                       !externalDrives.contains(url) {
                        externalDrives.append(url)
                        print("✅ Externes Gerät gefunden (alternativer Pfad): \(url.lastPathComponent)")
                    }
                }
            }
        }
        
        return externalDrives
    }
    
    /// Gibt eine lesbare Liste der gefundenen externen Geräte zurück
    static func getExternalStorageInfo() -> String {
        let drives = checkForExternalStorage()
        
        if drives.isEmpty {
            return "❌ Keine externen Speichergeräte erkannt.\n\nDas könnte bedeuten:\n• Das Gerät wird von iOS nicht als USB Mass Storage erkannt\n• Der Adapter unterstützt kein UMS-Protokoll\n• Das Laufwerk benötigt zusätzliche Stromversorgung\n• Das Dateisystem ist nicht kompatibel"
        }
        
        var info = "✅ Gefundene externe Geräte:\n\n"
        for drive in drives {
            if let name = try? drive.resourceValues(forKeys: [.volumeNameKey]).volumeName {
                info += "📁 \(name)\n   Pfad: \(drive.path)\n\n"
            } else {
                info += "📁 \(drive.lastPathComponent)\n   Pfad: \(drive.path)\n\n"
            }
        }
        
        return info
    }
}

