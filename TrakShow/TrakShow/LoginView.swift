//
//  LoginView.swift
//  TrakShow
//
//  Created by Gabriel Mannheimer on 2/8/24.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @StateObject var trakShowManager: TrakShowManager
    var body: some View {
        ZStack{
            trakShowManager.bkgrColor.ignoresSafeArea()
            VStack{
                HStack{
                    Text("Login")
                        .foregroundStyle(Color.white)
                        .padding(.leading)
                        .font(.system(size: 35))
                        .bold()
                    Spacer()
                    Text("")
                        
                }
                .padding()
                HStack{
                    Text("Please Login to continue")
                        .foregroundStyle(Color.gray)
                        .padding(.leading)
                        .font(.system(size: 15))
                        .bold()
                    Spacer()
                    Text("")
                        
                }
                    .padding(.leading)
                HStack(spacing: 10){
                    Image(systemName: "mail")
                        .padding(.leading)
                    TextField("", text: $email, prompt: {
                        Text("Email")
                            .foregroundColor(.white)
                    }())
                }
                .foregroundColor(.white)
                    .frame(width:350, height: 50)
                    .background(trakShowManager.logintxtColor)
                    .cornerRadius(20)
                    .padding()
                HStack(spacing: 10){
                    Image(systemName: "lock")
                        .padding(.leading)
                    SecureField("", text: $password, prompt: {
                        Text("Password")
                            .foregroundColor(.white)
                    }())
                }
                .foregroundColor(.white)
                    .frame(width:350, height: 50)
                    .background(trakShowManager.logintxtColor)
                    .cornerRadius(20)
                    .padding()
                    Button(action:{
                        Task{ await trakShowManager.loginWithEmailPassword(email: email, password: password)
                        }
                        }){
                        Text("Login")
                            .foregroundStyle(Color.black)
                            .font(.title)
                            .padding()
                            .frame(width: 250, height: 70)
                            .background(trakShowManager.btnColor)
                            .cornerRadius(20)
                    }
                Text("or")
                    .foregroundStyle(Color.gray)
                Button(action:{}){
                    HStack{
                        Text("Login with")
                        Image("glogo")
                            .resizable()
                            .frame(width: 50, height: 40)
                    }
                        .foregroundStyle(Color.black)
                        .font(.system(size: 20))
                        .padding()
                        .frame(width: 250, height: 70)
                        .background(trakShowManager.btnColor)
                        .cornerRadius(20)
                }
                
            }
        }
    }
}

#Preview {
    LoginView(trakShowManager: TrakShowManager())
}
