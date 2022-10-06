import Foundation
import CloudFiles
import SwiftyDropbox

extension Upload {
  public static func dropbox() -> Upload {
    Upload { data, completion in
      guard let client = DropboxClientsManager.authorizedClient else { fatalError() }
      client
        .files
        .listFolder(path: "/backup")
        .response { result, error in
          if let error {
            completion(.failure(NSError(domain: error.description, code: 0)))
            return
          }
          let uploadInternal: (Data) -> Void = { file in
            client
              .files
              .upload(path: "/backup/backup.xxm", mode: .overwrite, input: file)
              .response { response, error in
                if let error {
                  completion(.failure(NSError(domain: error.description, code: 3)))
                  return
                }

                if let response {
                  print(">>> Size: \(Float(response.size))")
                  print(">>> Modified: \(response.serverModified)")
                  print(">>> Path: \(String(describing: response.pathLower))")
                }
              }
          }
          guard result != nil else {
            client.files
              .createFolderV2(path: "/backup")
              .response { _, error in
                if let error {
                  completion(.failure(NSError(domain: error.description, code: 1)))
                  return
                }

                uploadInternal(data)
              }
            return
          }

          uploadInternal(data)
        }
    }
  }
}
