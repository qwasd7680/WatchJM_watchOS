//
//  ContentView.swift
//  WatchJM Watch App
//
//  Created by 周敬博 on 2025/8/16.
//

import SwiftUI
import Cepheus

struct MainView: View {
	let rankList:[Album]
	var jmurl:String
	@State var isGoToSearch = false
	var body: some View {
		NavigationView {
			VStack{
				List(rankList) { list in
					NavigationLink(destination: DetailView(jmurl: jmurl, album: list)){
						Text(list.title)
					}
				}
			}
		}.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button(action: {
					isGoToSearch = true
				}) {
					Label("搜索", systemImage: "magnifyingglass")
				}.sheet(isPresented: $isGoToSearch, content: {SearchView()})
			}
		}
	}
}

struct ContentView: View {
	@State var rankList:[Album] = []
	@AppStorage("jmurl") var jmurl = ""
	let NetWorkManager = Net()
	var body: some View {
		NavigationStack{
			TabView{
				MainView(rankList: rankList, jmurl: jmurl)
					.tag(0)
					.onAppear{
						Task{
							do {
								rankList = try await NetWorkManager.GetRank(jmurl: jmurl)
							} catch {
								print("Error: \(error)")
							}
						}
					}
				DownloadedView()
					.tag(1)
				SettingView()
					.tag(2)
			}
		}
	}
}

#Preview {
	ContentView()
}
