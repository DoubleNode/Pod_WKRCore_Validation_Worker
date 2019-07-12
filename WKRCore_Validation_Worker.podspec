Pod::Spec.new do |s|

  s.name         = "WKRCore_Validation_Worker"
  s.version      = "0.3.4"
  s.summary      = "A Core Validation Worker."

  s.description  = <<-DESC
                    A basic core worker for validating user input
                   DESC

  s.homepage     = "https://github.com/DoubleNode/Pod_WKRCore_Validation_Worker"
  s.license      = { :type => "PRIVATE", :file => "README.md" }

  s.author             = { "Darren Ehlers" => "me@darrenehlers.com" }
  s.social_media_url   = "http://twitter.com/ehlersd"

  s.platform        = :ios, "11.0"
  s.source          = { :git => "https://github.com/DoubleNode/Pod_WKRCore_Validation_Worker.git", :tag => "#{s.version}" }
  s.swift_version   = "4.2"

  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  s.public_header_files = "Classes/**/*.h"

  s.requires_arc = true

  s.dependency "WKRCrash_Workers"

end
