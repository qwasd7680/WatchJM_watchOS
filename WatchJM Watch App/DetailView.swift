//
//  DetailView.swift
//  WatchJM
//
//  Created by 周敬博 on 2025/8/19.
//

import SwiftUI
import SDWebImageSwiftUI

struct DetailView: View {
    var jmurl:String
    let album:Album
    var body: some View{
        ScrollView{
            VStack{
                WebImage(url: URL(string:jmurl+"/info/"+album.aid))
                    .resizable()
                    .indicator(.activity)
                    .transition(.fade(duration: 0.5))
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .padding(.bottom, 5)
                Text(album.title)
                    .font(.title)
            }
        }
    }
}
#Preview {
    DetailView(jmurl: "http://192.168.31.42:11111", album: Album(title: "血姬", aid: "533212",cover:"https://cvws.icloud-content.com.cn/B/AS-hqJVGoA9FKkeyUS_bSLvP4ODTAdJZMuauY9SE5gwt_dEKzqAae4W-/00001.webp?o=Av3qfVSwIUNxifvBKbxNmDbi-oyEBe8JGe8uSiEdhSQF&v=1&x=3&a=CAogu1PeoTk32RKUV10c5bB0tTv1AqImHE372h3qfKIM7moSbxDJ0MG-jDMYya2dwIwzIgEAUgTP4ODTWgQae4W-aicfdlRfw-NQoTb_B8ihnYDM9A8fFkEOQ8eJHtSjhJTWDEIx2uwblsVyJwdoxogtD3eRI21BrXDXLKpBOqyynpaN5GdENxGoKciybS_iVMR_CQ&e=1755702580&fl=&r=21588769-2c19-4077-ab57-43e1868ff163-1&k=qWJqG434Dr6jCAk4z5h0sA&ckc=com.apple.clouddocs&ckz=com.apple.CloudDocs&p=229&s=e7hOQChz1X5tfmUC0motK_MB02Q"))
}
