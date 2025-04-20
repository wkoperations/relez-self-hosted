require "test_helper"

class AppTest < ActiveSupport::TestCase
  setup do
    # Clear any existing records
    App.delete_all
  end

  test "validates name format" do
    app = App.new(name: "valid-name_123", image: "traefik:latest")
    assert app.valid?

    app = App.new(name: "Invalid Name", image: "traefik:latest")
    assert_not app.valid?
    assert_includes app.errors[:name], "only allows lowercase letters, numbers, hyphens and underscores"
  end

  test "validates docker image format" do
    # Simple Docker Hub images
    assert App.new(name: "test", image: "traefik:latest").valid?
    assert App.new(name: "test", image: "nginx:1.25.3").valid?
    assert App.new(name: "test", image: "redis:7.2").valid?
    assert App.new(name: "test", image: "postgres:15-alpine").valid?

    # Custom Docker Hub images
    assert App.new(name: "test", image: "username/repo:tag").valid?
    assert App.new(name: "test", image: "organization/repo:1.0.0").valid?

    # Private registry images
    assert App.new(name: "test", image: "registry.example.com:5000/repo:tag").valid?
    assert App.new(name: "test", image: "my-registry.com/project/repo:1.0").valid?

    # Local registry images
    assert App.new(name: "test", image: "localhost:5000/repo:tag").valid?

    # Invalid images
    invalid_images = [
      "invalid:tag:with:colons",
      "invalid@image",
      "invalid#image",
      "invalid$image",
      "invalid%image",
      "invalid^image",
      "invalid&image",
      "invalid*image",
      "invalid(image",
      "invalid)image",
      "invalid=image",
      "invalid+image",
      "invalid[image",
      "invalid]image",
      "invalid{image",
      "invalid}image",
      "invalid|image",
      "invalid\\image",
      "invalid<image",
      "invalid>image",
      "invalid,image",
      "invalid?image",
      "invalid!image",
      "invalid~image",
      "invalid`image",
      "invalid'image",
      "invalid\"image",
      "invalid image"
    ]

    invalid_images.each do |image|
      app = App.new(name: "test", image: image)
      assert_not app.valid?, "Expected #{image} to be invalid"
      assert_includes app.errors[:image], "must be a valid Docker image name or URL with optional tag"
    end
  end

  test "validates system attribute" do
    app = App.new(name: "test", image: "traefik:latest")
    assert_not app.system, "system should default to false"

    app.system = true
    assert app.system
  end
end
