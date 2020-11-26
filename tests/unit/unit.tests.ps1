<# Tests:
- Existance of required keys per documented requirements
- Tests the correct type
- Tests the correct default values
- Tests that enums contains all the right values
- Tests that enums do not contain extra (unauthorized values)
- Tests that ints have the correct Base
- Tests that ints have the correct Max
- Tests that ints have the correct Min
- Tests that ints have the correct Step
#>

# This is the MSFT definition
$AdapterDefinition = [AdapterDefinition]::new()

$Adapters | ForEach-Object {
    $thisAdapter = $_
    $thisAdapterAdvancedProperties = $AdapterAdvancedProperties | Where-Object Name -eq $thisAdapter.Name

    # This is the configuration from the remote pNIC
    $abc = Get-AdvancedRegistryKeyInfo -interfaceName $thisAdapter.Name -AdapterAdvancedProperties $thisAdapterAdvancedProperties
    $AdapterConfiguration = Invoke-Command ${function:Get-AdvancedRegistryKeyInfo} -Session $PSSession -ArgumentList $thisAdapter.Name, $thisAdapterAdvancedProperties

    # This turns the enums from the requirements into an array with the Remove method
    [System.Collections.ArrayList] $RemainingRequirements = $Requirements[0..$Requirements.count].ForEach({ $_.foreach({ $_ }) })

    # Device.Network.LAN.Base.100MbOrGreater Windows Server Ethernet devices must be able to link at 1Gbps or higher speeds
    if ($thisAdapter.Speed -ge 1000000000) { $PassFail = $pass }
    else { $PassFail = $fail; $testsFailed ++ }

    "[$PassFail] $($thisAdapter.Name) is 1Gbps or higher" | Out-File -FilePath $Log -Append
    Remove-Variable -Name PassFail -ErrorAction SilentlyContinue

    Switch -Wildcard ($AdapterConfiguration) {

        { $_.RegistryKeyword -eq '*JumboPacket' } {

            # *JumboPacket: RegistryDefaultValue
            Test-RegistryDefaultValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.JumboPacket

            # *JumboPacket: DisplayParameterType
            Test-DisplayParameterType -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.JumboPacket

            # *JumboPacket: NumericParameterBaseValue
            Test-NumericParameterBaseValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.JumboPacket

            # *JumboPacket: NumericParameterStepValue
            Test-NumericParameterStepValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.JumboPacket

            # *JumboPacket: NumericParameterMaxValue
            Test-NumericParameterMaxValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.JumboPacket -OrGreater

            # *JumboPacket: NumericParameterMinValue
            Test-NumericParameterMinValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.JumboPacket -OrLess

        }

        { $_.RegistryKeyword -eq '*LsoV2IPv4' } {

            # *LsoV2IPv4: RegistryDefaultValue
            Test-RegistryDefaultValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.LSO.LsoV2IPv4

            # *LsoV2IPv4: DisplayParameterType
            Test-DisplayParameterType -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.LSO.LsoV2IPv4

            # *LsoV2IPv4: ValidRegistryValues
            Test-ContainsAllMSFTRequiredValidRegistryValues  -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.LSO.LsoV2IPv4
            Test-ContainsOnlyMSFTRequiredValidRegistryValues -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.LSO.LsoV2IPv4

        }

        { $_.RegistryKeyword -eq '*LsoV2IPv6' } {

            # *LsoV2IPv6: RegistryDefaultValue
            Test-RegistryDefaultValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.LSO.LsoV2IPv6

            # *LsoV2IPv6: DisplayParameterType
            Test-DisplayParameterType -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.LSO.LsoV2IPv6

            # *LsoV2IPv6: ValidRegistryValues
            Test-ContainsAllMSFTRequiredValidRegistryValues  -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.LSO.LsoV2IPv6
            Test-ContainsOnlyMSFTRequiredValidRegistryValues -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.LSO.LsoV2IPv6

        }

        { $_.RegistryKeyword -eq '*NetworkDirect' } {

            # *NetworkDirect: RegistryDefaultValue
            Test-RegistryDefaultValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.NDKPI.NetworkDirect

            # *NetworkDirect: DisplayParameterType
            Test-DisplayParameterType -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.NDKPI.NetworkDirect

            # *NetworkDirect: ValidRegistryValues
            Test-ContainsAllMSFTRequiredValidRegistryValues  -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.NDKPI.NetworkDirect
            Test-ContainsOnlyMSFTRequiredValidRegistryValues -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.NDKPI.NetworkDirect

        }

        { $_.RegistryKeyword -eq '*NetworkDirectTechnology' } {

            # *NetworkDirectTechnology: RegistryDefaultValue
            Test-RegistryDefaultValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.NDKPI.NetworkDirectTechnology

            # *NetworkDirectTechnology: DisplayParameterType
            Test-DisplayParameterType -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.NDKPI.NetworkDirectTechnology

            # *NetworkDirectTechnology: ValidRegistryValues
                # As the adapter can choose to support one or more of these types, we will only check that the contained values are within the MSFT defined range
                # We will not test to ensure that all defined values are found unlike other enums (because an adapter may support both RoCE and RoCEv2 but not iWARP and visa versa)
            Test-ContainsOnlyMSFTRequiredValidRegistryValues -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.NDKPI.NetworkDirectTechnology

        }

        { $_.RegistryKeyword -eq '*NumaNodeId' } {

            # *NumaNodeId: RegistryDefaultValue
            Test-RegistryDefaultValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSSClass.NumaNodeId

            # *NumaNodeId: DisplayParameterType
            Test-DisplayParameterType -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSSClass.NumaNodeId

            # *NumaNodeId: NumericParameterBaseValue
            Test-NumericParameterBaseValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSSClass.NumaNodeId

            # *NumaNodeId: NumericParameterStepValue
            Test-NumericParameterStepValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSSClass.NumaNodeId

            # *NumaNodeId: NumericParameterMaxValue
            Test-NumericParameterMaxValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSSClass.NumaNodeId

            # *NumaNodeId: NumericParameterMinValue
            Test-NumericParameterMinValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSSClass.NumaNodeId

        }

        { $_.RegistryKeyword -eq '*PriorityVLANTag' } {

            # *PriorityVLANTag: RegistryDefaultValue
            Test-RegistryDefaultValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.PriorityVLANTag

            # *PriorityVLANTag: DisplayParameterType
            Test-DisplayParameterType -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.PriorityVLANTag

            # *PriorityVLANTag: ValidRegistryValues
            Test-ContainsAllMSFTRequiredValidRegistryValues  -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.PriorityVLANTag
            Test-ContainsOnlyMSFTRequiredValidRegistryValues -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.PriorityVLANTag

        }

        { $_.RegistryKeyword -eq '*QOS' } {

            # *QOS: RegistryDefaultValue
            Test-RegistryDefaultValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.QOS

            # *QOS: DisplayParameterType
            Test-DisplayParameterType -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.QOS

            # *QOS: ValidRegistryValues
            Test-ContainsAllMSFTRequiredValidRegistryValues  -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.QOS
            Test-ContainsOnlyMSFTRequiredValidRegistryValues -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.QOS

        }

        { $_.RegistryKeyword -eq '*ReceiveBuffers' } {

            # *ReceiveBuffers: DisplayParameterType
            Test-DisplayParameterType -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.Buffers.ReceiveBuffers

        }

        { $_.RegistryKeyword -eq '*RSCIPv4' } {

            # *RSCIPv4: RegistryDefaultValue
            Test-RegistryDefaultValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSC.RSCIPv4

            # *RSCIPv4: DisplayParameterType
            Test-DisplayParameterType -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSC.RSCIPv4

            # *RSCIPv4: ValidRegistryValues
            Test-ContainsAllMSFTRequiredValidRegistryValues  -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSC.RSCIPv4
            Test-ContainsOnlyMSFTRequiredValidRegistryValues -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSC.RSCIPv4

        }

        { $_.RegistryKeyword -eq '*RSCIPv6' } {

            # *RSCIPv6: RegistryDefaultValue
            Test-RegistryDefaultValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSC.RSCIPv6

            # *RSCIPv6: DisplayParameterType
            Test-DisplayParameterType -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSC.RSCIPv6

            # *RSCIPv6: ValidRegistryValues
            Test-ContainsAllMSFTRequiredValidRegistryValues  -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSC.RSCIPv6
            Test-ContainsOnlyMSFTRequiredValidRegistryValues -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSC.RSCIPv6

        }

        { $_.RegistryKeyword -eq '*RSS' } {

            # *RSS: RegistryDefaultValue
            Test-RegistryDefaultValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSSClass.RSS

            # *RSS: DisplayParameterType
            Test-DisplayParameterType -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSSClass.RSS

            # *RSS: ValidRegistryValues
            Test-ContainsAllMSFTRequiredValidRegistryValues  -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSSClass.RSS
            Test-ContainsOnlyMSFTRequiredValidRegistryValues -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSSClass.RSS

        }

        { $_.RegistryKeyword -eq '*RSSBaseProcGroup' } {

            # *RSSBaseProcGroup: RegistryDefaultValue
            Test-RegistryDefaultValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSSClass.RSSBaseProcGroup

            # *RSSBaseProcGroup: DisplayParameterType
            Test-DisplayParameterType -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSSClass.RSSBaseProcGroup -MaxValue 4

            # *RSSBaseProcGroup: NumericParameterBaseValue
            Test-NumericParameterBaseValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSSClass.RSSBaseProcGroup

            # *RSSBaseProcGroup: NumericParameterStepValue
            Test-NumericParameterStepValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSSClass.RSSBaseProcGroup

            # *RSSBaseProcGroup: NumericParameterMinValue
            Test-NumericParameterMinValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSSClass.RSSBaseProcGroup

        }

        { $_.RegistryKeyword -eq '*RSSBaseProcNumber' } {

            # *RSSBaseProcNumber: RegistryDefaultValue
            Test-RegistryDefaultValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSSClass.RSSBaseProcNumber

            # *RSSBaseProcNumber: DisplayParameterType
            Test-DisplayParameterType -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSSClass.RSSBaseProcNumber -MaxValue 4

            # *RSSBaseProcNumber: NumericParameterBaseValue
            Test-NumericParameterBaseValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSSClass.RSSBaseProcNumber

            # *RSSBaseProcNumber: NumericParameterStepValue
            Test-NumericParameterStepValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSSClass.RSSBaseProcNumber

            # *RSSBaseProcNumber: NumericParameterMinValue
            Test-NumericParameterMinValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.RSSClass.RSSBaseProcNumber

        }

        { $_.RegistryKeyword -eq '*SRIOV' } {

            # *SRIOV: RegistryDefaultValue
            Test-RegistryDefaultValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.SRIOV

            # *SRIOV: DisplayParameterType
            Test-DisplayParameterType -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.SRIOV

            # *SRIOV: ValidRegistryValues
            Test-ContainsAllMSFTRequiredValidRegistryValues  -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.SRIOV
            Test-ContainsOnlyMSFTRequiredValidRegistryValues -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.SRIOV

        }

        { $_.RegistryKeyword -eq '*TransmitBuffers' } {

            # *TransmitBuffers: DisplayParameterType
            Test-DisplayParameterType -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.Buffers.TransmitBuffers

        }

        { $_.RegistryKeyword -eq '*UsoIPv4' } {

            # *UsoIPv4: RegistryDefaultValue
            Test-RegistryDefaultValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.USO.UsoIPv4

            # *UsoIPv4: DisplayParameterType
            Test-DisplayParameterType -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.USO.UsoIPv4

        }

        { $_.RegistryKeyword -eq '*UsoIPv6' } {

            # *UsoIPv6: RegistryDefaultValue
            Test-RegistryDefaultValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.USO.UsoIPv6

            # *UsoIPv6: DisplayParameterType
            Test-DisplayParameterType -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.USO.UsoIPv6

        }

        { $_.RegistryKeyword -eq '*VMQ' } {

            # *VMQ: RegistryDefaultValue
            Test-RegistryDefaultValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.VMQ

            # *VMQ: DisplayParameterType
            Test-DisplayParameterType -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.VMQ

        }

        { $_.RegistryKeyword -eq 'VLANID' } {
            # Device.Network.LAN.Base.PriorityVLAN - Since all WS devices must be -ge 1Gbps, they must implement
            # Ethernet devices that implement link speeds of gigabit or greater must implement Priority & VLAN tagging according to the IEEE 802.1q specification.

            # VLANID: RegistryDefaultValue
            Test-RegistryDefaultValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.VLANID

            # VLANID: DisplayParameterType
            Test-DisplayParameterType -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.VLANID

            # VLANID: NumericParameterBaseValue
            Test-NumericParameterBaseValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.VLANID

            # VLANID: NumericParameterStepValue
            Test-NumericParameterStepValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.VLANID

            # VLANID: NumericParameterMaxValue
            Test-NumericParameterMaxValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.VLANID

            # VLANID: NumericParameterMinValue
            Test-NumericParameterMinValue -AdvancedRegistryKey $_ -DefinitionPath $AdapterDefinition.VLANID
        }

        '*' {
            # Always Remove if in the remaining requirements list
            $RemainingRequirements.Remove( $_.RegistryKeyword )
        }
    }

<#
        # Each value in the adapter definition must be a possible value for the feature
        # Iterate through the list of possible values
        $($AdapterDefinition.RSC.RSS.PossibleValues) | ForEach-Object {
            $thisPossibleValue = $_

            # Ensure thisPossibleValue is in the list specified by the IHV
            It "*RSS: Should have the possible value of $thisPossibleValue" {
                $thisPossibleValue | Should -BeIn ($thisAdapterAdvancedProperties | Where RegistryKeyword -eq `*RSS).ValidRegistryValues
            }
        }

        # The opposite case. The adapter cannot support extra options beyond that specified in the spec.
        # Iterate through the list of possible values
        ($thisAdapterAdvancedProperties | Where RegistryKeyword -eq `*RSS).ValidRegistryValues | ForEach-Object {
            $thisPossibleValue = $_

            # To reduce redundancy we'll pretest the value from the adapter to ensure its not in the MSFT Definition
            # If it is not in the MSFT definition, then that is a failure.
            if ($thisPossibleValue -notin $($AdapterDefinition.RSC.RSS.PossibleValues)) {
                # Ensure thisPossibleValue is in the list specified by MSFT
                It "*RSS: Should only the possible value of $thisPossibleValue" {
                    $thisPossibleValue | Should -BeIn $($AdapterDefinition.RSC.RSS.PossibleValues)
                }
            }
        }
    #>
}
