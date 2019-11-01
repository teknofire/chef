require "spec_helper"
require "fauxhai"

def pf_reports_true_for(*args)
  args.each do |method|
    it "reports true for #{method}" do
      expect(described_class.send(method, node)).to be true
    end
  end
  (PLATFORM_FAMILY_HELPERS - [ :windows_ruby_platform? ] - args).each do |method|
    it "reports false for #{method}" do
      expect(described_class.send(method, node)).to be false
    end
  end
end

RSpec.describe ChefUtils::PlatformFamily do
  let(:node) { Fauxhai.mock(options).data }

  ( HELPER_MODULES - [ described_class ] ).each do |klass|
    it "does not have methods that collide with #{klass}" do
      expect((klass.methods - Module.methods) & PLATFORM_FAMILY_HELPERS).to be_empty
    end
  end

  ( PLATFORM_FAMILY_HELPERS - [ :windows_ruby_platform? ]).each do |helper|
    it "has the #{helper} in the ChefUtils module" do
      expect(ChefUtils).to respond_to(helper)
    end
  end

  context "on ubuntu" do
    let(:options) { { platform: "ubuntu" } }

    pf_reports_true_for(:debian?)
  end

  context "on raspbian" do
    let(:options) { { platform: "raspbian" } }

    pf_reports_true_for(:debian?)
  end

  context "on linuxmint" do
    let(:options) { { platform: "linuxmint" } }

    pf_reports_true_for(:debian?)
  end

  context "on debian" do
    let(:options) { { platform: "debian" } }

    pf_reports_true_for(:debian?)
  end

  context "on aix" do
    let(:options) { { platform: "aix" } }

    pf_reports_true_for(:aix?)
  end

  context "on amazon" do
    let(:options) { { platform: "amazon" } }

    pf_reports_true_for(:amazon?, :amazon_linux?, :rpm_based?, :fedora_derived?)
  end

  context "on arch" do
    let(:options) { { platform: "arch" } }

    pf_reports_true_for(:arch?, :arch_linux?)
  end

  context "on centos" do
    let(:options) { { platform: "centos" } }

    pf_reports_true_for(:rhel?, :rpm_based?, :fedora_derived?, :redhat_based?, :el?)
  end

  context "on clearos" do
    let(:options) { { platform: "clearos" } }

    pf_reports_true_for(:rhel?, :rpm_based?, :fedora_derived?, :redhat_based?, :el?)
  end

  context "on dragonfly4" do
    let(:options) { { platform: "dragonfly4" } }

    pf_reports_true_for(:dragonflybsd?)
  end

  context "on fedora" do
    let(:options) { { platform: "fedora" } }

    pf_reports_true_for(:fedora?, :rpm_based?, :fedora_derived?, :redhat_based?)
  end

  context "on freebsd" do
    let(:options) { { platform: "freebsd" } }

    pf_reports_true_for(:freebsd?, :bsd_based?)
  end

  context "on gentoo" do
    let(:options) { { platform: "gentoo" } }

    pf_reports_true_for(:gentoo?)
  end

  context "on mac_os_x" do
    let(:options) { { platform: "mac_os_x" } }

    pf_reports_true_for(:mac_os_x?, :mac?, :osx?, :macos?)
  end

  context "on openbsd" do
    let(:options) { { platform: "openbsd" } }

    pf_reports_true_for(:openbsd?, :bsd_based?)
  end

  context "on opensuse" do
    let(:options) { { platform: "opensuse" } }

    pf_reports_true_for(:suse?, :rpm_based?)
  end

  context "on oracle" do
    let(:options) { { platform: "oracle" } }

    pf_reports_true_for(:rhel?, :rpm_based?, :fedora_derived?, :redhat_based?, :el?)
  end

  context "on redhat" do
    let(:options) { { platform: "redhat" } }

    pf_reports_true_for(:rhel?, :rpm_based?, :fedora_derived?, :redhat_based?, :el?)
  end

  context "on smartos" do
    let(:options) { { platform: "smartos" } }

    pf_reports_true_for(:smartos?, :solaris_based?)
  end

  context "on solaris2" do
    let(:options) { { platform: "solaris2" } }

    pf_reports_true_for(:solaris?, :solaris2?, :solaris_based?)
  end

  context "on suse" do
    let(:options) { { platform: "suse" } }

    pf_reports_true_for(:suse?, :rpm_based?)
  end

  context "on windows" do
    let(:options) { { platform: "windows" } }

    pf_reports_true_for(:windows?)
  end

  context "node-independent windows APIs" do
    if RUBY_PLATFORM =~ /mswin|mingw32|windows/
      it "reports true for :windows_ruby_platform?" do
        expect(described_class.windows_ruby_platform?).to be true
      end
    else
      it "reports false for :windows_ruby_platform?" do
        expect(described_class.windows_ruby_platform?).to be false
      end
    end
  end
end
