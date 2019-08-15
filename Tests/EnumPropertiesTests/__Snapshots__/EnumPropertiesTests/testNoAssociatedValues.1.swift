enum CodingKeys: String, CodingKey {
  case id
  case name
  case email

  var id: Void? {
    guard case .id = self else { return nil }
    return ()
  }

  var name: Void? {
    guard case .name = self else { return nil }
    return ()
  }

  var email: Void? {
    guard case .email = self else { return nil }
    return ()
  }
}
