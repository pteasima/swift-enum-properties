enum CodingKeys: String, CodingKey {
  case id
  case name
  case email

  var id: Void? {
    get {
      guard case .id = self else { return nil }
      return ()
    }
    set {
      guard let _ = newValue else { return }
      self = .id
    }
  }

  var name: Void? {
    get {
      guard case .name = self else { return nil }
      return ()
    }
    set {
      guard let _ = newValue else { return }
      self = .name
    }
  }

  var email: Void? {
    get {
      guard case .email = self else { return nil }
      return ()
    }
    set {
      guard let _ = newValue else { return }
      self = .email
    }
  }
}
