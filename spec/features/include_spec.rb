
describe ConfigHound do

  def load(path)
    ConfigHound.load(path)
  end

  let(:config) { load("config.yml") }

  context "when file includes another" do

    given_resource "config.yml", %{
      foo: 42
      _include: included.yml
    }

    given_resource "included.yml", %{
      foo: 1
      bar: 2
    }

    it "merges in the included file" do
      expect(config).to eq(
        "foo" => 42,
        "bar" => 2
      )
    end

  end

  context "when the included file has a different format" do

    given_resource "config.yml", %{
      foo: 42
      _include: included.toml
    }

    given_resource "included.toml", %{
      foo = 1
      bar = 2
    }

    it "doesn't matter" do
      expect(config).to eq(
        "foo" => 42,
        "bar" => 2
      )
    end

  end

  context "with multiple levels of inclusion" do

    given_resource "config.yml", %{
      from_config: C
      _include: a.yml
    }

    given_resource "a.yml", %{
      from_a: A
      _include: b.yml
    }

    given_resource "b.yml", %{
      from_b: B
    }

    it "merges in both files" do
      expect(config).to eq(
        "from_config" => "C",
        "from_a" => "A",
        "from_b" => "B"
      )
    end

  end

  context "with relative inclusion" do

    given_resource "config.yml", %{
      from_config: C
      _include: subdir/a.yml
    }

    given_resource "subdir/a.yml", %{
      from_a: A
      _include: b.yml
    }

    given_resource "subdir/b.yml", %{
      from_b: B
    }

    it "resolves the relative references" do
      expect(config).to eq(
        "from_config" => "C",
        "from_a" => "A",
        "from_b" => "B"
      )
    end

  end

end


