import UIKit
import RegexBuilder

public enum Provisioning {
    public static let apsEnvironmentIsDevelopment: Bool = {
        guard let url = Bundle.main.url(forResource: "embedded", withExtension: "mobileprovision"), let data = try? Data(contentsOf: url), let string = String(data: data, encoding: .ascii) else {
            return false
        }
        
        let regex = Regex {
            "<key>aps-environment</key>"
            ZeroOrMore {
                .whitespace
            }
            "<string>development</string>"
        }
        
        return string.contains(regex)
    }()
}
