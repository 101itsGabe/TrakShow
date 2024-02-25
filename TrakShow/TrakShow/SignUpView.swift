//
//  SignUpView.swift
//  TrakShow
//
//  Created by Gabriel Mannheimer on 2/14/24.
//

import SwiftUI

struct SignUpView: View {
    @StateObject var trakShowManager: TrakShowManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    var body: some View {
        ZStack{
            trakShowManager.bkgrColor
                .ignoresSafeArea()
            ScrollView{
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
                    Spacer()
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
                        Image(systemName: "person.fill")
                            .padding(.leading)
                        TextField("", text: $email, prompt: {
                            Text("Username")
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
                    
                    HStack(spacing: 10){
                        Image(systemName: "lock")
                            .padding(.leading)
                        SecureField("", text: $confirmPassword, prompt: {
                            Text("Confirm Password")
                                .foregroundColor(.white)
                        }())
                    }
                    .foregroundColor(.white)
                    .frame(width:350, height: 50)
                    .background(trakShowManager.logintxtColor)
                    .cornerRadius(20)
                    .padding()
                    
                    Spacer()
                    Button(action:{
                        if password == confirmPassword{
                            Task{
                                await trakShowManager.signUp(email: email, password: confirmPassword)
                            }
                        }
                    }){
                        Text("Sign Up")
                            .foregroundStyle(Color.black)
                            .font(.title)
                            .padding()
                            .frame(width: 250, height: 70)
                            .background(trakShowManager.btnColor)
                            .cornerRadius(20)
                    }
                    Spacer()
                    
                    if password != confirmPassword{
                        Text("Password Do Not Match")
                            .padding()
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }
}

#Preview {
    SignUpView(trakShowManager: TrakShowManager())
}
