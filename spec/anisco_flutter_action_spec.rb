describe Fastlane::Actions::AniscoFlutterAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The anisco_flutter plugin is working!")

      Fastlane::Actions::AniscoFlutterAction.run(nil)
    end
  end
end
