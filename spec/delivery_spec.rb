require 'spec_helper'
require 'delivery'
require 'archive'
require 'date'
require 'date_fmt'

include DateFmt

describe Delivery do
    require 'delivery'
    attr_reader :delivery, :son, :father, :grandfather
    before do
        @delivery = Delivery.new()
        @son = mock 'son'
        @father = mock 'father'
        @grandfather = mock 'grandfather'
        @son.stub!(:should_be_used?).and_return true
    end

    
    describe 'deliver' do
        attr_reader :archive
        before do
            @archive = Archive.new(nil,nil,nil)
        end

        describe 'if no rotation strategy defined' do
            it 'raises an exception' do
                lambda {
                    doit
                }.should raise_exception(DeliveryException)
            end
        end
           
        describe 'if a son strategy defined' do
            before do 
                delivery.son= son
            end
            
            it 'delegates to the son' do
                expect_to_delegate_to_son            
                doit
            end
            
            describe "and father too" do
                before do
                    delivery.father = father
                end
                
                it 'delegates to the father if it should be used' do
                    expect_to_delegate_to_father            
                    doit
                end
                
                describe "and grandfather too" do
                    it 'delegates to the grandfather if it should be used' do
                        delivery.grandfather = grandfather
                        expect_to_delegate_to_grandfather            
                        doit
                    end
                end
            end
        end

        def expect_to_delegate_to_son
            son.should_receive(:execute).with(archive).and_return true
        end
        
        def expect_to_delegate_to_father
            son.should_receive(:execute).never
            father.should_receive(:execute).with(archive).and_return true
        end
        
        def expect_to_delegate_to_grandfather
            son.should_receive(:execute).never
            father.should_receive(:execute).never
            grandfather.should_receive(:execute).with(archive).and_return true
        end
        
        def doit
            delivery.deliver(archive)
        end
        
    end
    
end

require 'date'
require 'runt'
include Runt

describe BackupKind do
    attr_reader :backup_kind
    
    before do
        @backup_kind = BackupKind.new('son',nil)
    end
    
    describe "execute" do
        attr_reader :backup_kind, :archive
        before do
            @backup_kind = BackupKind.new('son', nil)
            @archive = mock('archive')
        end
        
        describe " - by default" do
            it "sends the created archive to the destination" do
                archive.should_receive(:create).with('son') 
                backup_kind.execute(archive).should be_true
            end
            
            it "removes destinations for this backup_kind until it matches the maximum to keep" do
                backup_kind.number_to_keep = 1
                archive.should_receive(:create).with('son') 
                archive.should_receive(:remove_exceeding).with('son', 1) 
                backup_kind.execute(archive).should be_true
            end
        end

        describe " - given a delivery of this type has never happened" do
            before do
                archive.stub!(:exists?).with('son').and_return false
            end
            
            it "sends the file to a rotated filename in the destination directory by default" do
                archive.should_receive(:create).with('son') 
                backup_kind.execute(archive).should be_true
            end
        end

        describe "- given a delivery of this type happened before" do
            before do
                archive.stub!(:exists?).with('son').and_return true
            end
            
            describe "- and it should happen on each last friday" do
                before do
                    backup_kind.should_run_on_each last_friday 
                end
                it "creates no archive if the date does not match the runt expression" do
                    archive.should_receive(:create).never
                    backup_kind.execute(archive, Date.parse("29-07-2010")).should be_false
                end
                
                it "creates the archive if the date does matches the runt expression" do
                    archive.should_receive(:create).with('son')
                    backup_kind.execute(archive, Date.parse("30-07-2010")).should be_true
                end

            end        
        end 
    end
end
