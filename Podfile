platform :ios, '12.0'

def appodeal
  pod 'APDAdColonyAdapter', '2.7.4.1'
  pod 'APDAmazonAdsAdapter', '2.7.4.1'
  pod 'APDAppLovinAdapter', '2.7.4.1'
  pod 'APDAppodealAdExchangeAdapter', '2.7.4.1'
  pod 'APDChartboostAdapter', '2.7.4.1'
  pod 'APDFacebookAudienceAdapter', '2.7.4.1'
  pod 'APDGoogleAdMobAdapter', '2.7.4.1'
  pod 'APDInMobiAdapter', '2.7.4.1'
  pod 'APDInnerActiveAdapter', '2.7.4.1'
  pod 'APDIronSourceAdapter', '2.7.4.1'
  pod 'APDMintegralAdapter', '2.7.4.1'
  pod 'APDMyTargetAdapter', '2.7.4.1'
  pod 'APDOguryAdapter', '2.7.4.1'
  pod 'APDOpenXAdapter', '2.7.4.1'
  pod 'APDPubnativeAdapter', '2.7.4.1'
  pod 'APDSmaatoAdapter', '2.7.4.2'
  pod 'APDStartAppAdapter', '2.7.4.1'
  pod 'APDTapjoyAdapter', '2.7.4.1'
  pod 'APDUnityAdapter', '2.7.4.1'
  pod 'APDVungleAdapter', '2.7.4.1'
  pod 'APDYandexAdapter', '2.7.4.1' 
end

target 'Narrative Nurse' do
  use_frameworks!
  
  pod 'Firebase/Analytics'
  pod 'DropDown'
  pod 'SwiftGen'
  
  appodeal
end

target 'Sequence Builder' do
  use_frameworks!
  
  pod 'DropDown'
  pod 'SwiftGen'
end

post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
    end
end
