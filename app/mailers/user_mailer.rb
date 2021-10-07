class UserMailer < ApplicationMailer
  default from: 'from@example.com'

  def welcome_email(user)
    @user = user
    @url = 'https://localhost:3000/cats'
    
    mail(to: user.user_name, subject: 'Welcome to 99Cats!', from: 'everybody@appacademy.io')
  end
end
