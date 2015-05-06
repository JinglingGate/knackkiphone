import Foundation
import Alamofire

public enum Router:URLRequestConvertible {
    case Upload(fieldName: String, fileName: String, mimeType: String, fileContents: NSData, boundaryConstant:String, parameters:[String: AnyObject]?);
    
    var method: Alamofire.Method {
        switch self {
        default:
            return .POST
        }
    }
    
    var path: String {
        switch self {
        case Upload:
            return "/testupload.php"
        default:
            return "/"
        }
    }
    
    public var URLRequest: NSURLRequest {
        
        
        
        /*
            [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
                [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
                [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
                }];
            
            // add image data
            
            for (NSString *path in paths) {
                NSString *filename  = [path lastPathComponent];
                NSData   *data      = [NSData dataWithContentsOfFile:path];
                NSString *mimetype  = [self mimeTypeForPath:path];
                
                [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, filename] dataUsingEncoding:NSUTF8StringEncoding]];
                [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
                [httpBody appendData:data];
                [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
            [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
      */
        
        
        switch self {
        case .Upload(let fieldName, let fileName, let mimeType, let fileContents, let boundaryConstant, let parameters):
            
            
            
            
            
            
            
            
            
            
            
            
            
            //let boundaryStart = "--\(boundaryConstant)\r\n"
            //let boundaryEnd = "--\(boundaryConstant)--\r\n"
            
            
            
            for (key, value) in parameters! {
                requestBodyData.appendData("--\(boundaryConstant)/r/n".dataUsingEncoding(NSUTF8StringEncoding)!)
                requestBodyData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                requestBodyData.appendData("\(value)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            }
            
            let contentDispositionString = "Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\r\n"
            let contentTypeString = "Content-Type: \(mimeType)\r\n\r\n"
            
            //requestBodyData.appendData(boundaryStart.dataUsingEncoding(NSUTF8StringEncoding)!)
            
            /*/ add params (all params are strings)
            for (key, value) in parameters! {
                let string = "\(boundaryStart)Content-Disposition:form-data;name=\"\(key)\"\r\n\r\n\(value)\r\n"
                requestBodyData.appendData(string.dataUsingEncoding(NSUTF8StringEncoding)!)
            }*/
            
            [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, filename] dataUsingEncoding:NSUTF8StringEncoding]];
            [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
            [httpBody appendData:data];
            [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            
            requestBodyData.appendData(contentDispositionString.dataUsingEncoding(NSUTF8StringEncoding)!)
            requestBodyData.appendData(contentTypeString.dataUsingEncoding(NSUTF8StringEncoding)!)
            requestBodyData.appendData(fileContents)
            requestBodyData.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            requestBodyData.appendData("--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            mutableURLRequest.HTTPBody = requestBodyData
            
            //println("request data: \(requestBodyData)")
            
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0
            
        default:
            return mutableURLRequest
        }
    }
}