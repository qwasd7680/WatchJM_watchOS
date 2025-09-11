//
//  SearchView.swift
//  WatchJM
//
//  Created by 周敬博 on 2025/9/10.
//

import SwiftUI
import Cepheus
import SwiftyJSON

struct SearchView:View {
    @State var content:String = ""
    @State private var badNetwork = false
    @State var rankList:[Album] = []
    @State var isNotSearched = true
    @State var num = 1
    let NetWorkManager = Net()
    @AppStorage("useCepheus") var useCepheus:Bool = true
    @AppStorage("jmurl") var jmurl = "https://qwasd12w-jmcomic-api.hf.space"
    
    var body: some View {
        NavigationView{
            ZStack {
                if rankList.isEmpty {
                    CepheusKeyboard(input: $content,
                                    prompt: "请输入要搜索的内容",
                                    CepheusIsEnabled: useCepheus, allowEmojis: false,
                                    onSubmit: {
                        Task{
                            do {
                                try await searchAlbum(jmurl: jmurl, content: content, num: num)
                            }catch{
                                print(error)
                            }
                        }
                    })
                } else {
                    List(rankList) { list in
                        NavigationLink(destination: DetailView(jmurl: jmurl, album: list)){
                            Text(list.title)
                        }
                    }
                    if rankList.isEmpty && !badNetwork {
                        ProgressView()
                    }
                }
            }
        }
    }
    func searchAlbum(jmurl:String,content:String,num:Int) async throws {
        var tempList:[Album] = []
        guard let url = URL(string: jmurl+"/search/"+content+"/"+String(num)) else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let json = try! JSON(data: data)
        for dic in json {
            tempList.append(Album(title: dic.1["title"].string!, aid: dic.1["album_id"].string!))
        }
        do {
            DispatchQueue.main.async {
                self.rankList = tempList
                self.isNotSearched.toggle()
            }
        }
    }
}
