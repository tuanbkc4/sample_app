User.create!(
  name: "Admin",
  email: "tuan@gmail.com",
  password: "123456",
  password_confirmation: "123456",
  birthday: "1997/10/08",
  gender: "Male",
  admin: true,
  activated: true,
  activated_at: Time.zone.now
)

20.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "123456"
  birthday = "1997/10/08"
  gender = "Male"
  User.create!(
    name: name,
    email: email,
    password: password,
    password_confirmation: password,
    birthday: birthday,
    gender: gender,
    activated: true,
    activated_at: Time.zone.now
  )
end
