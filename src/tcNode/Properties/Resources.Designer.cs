﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.42000
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace TradeControl.Node.Properties {
    using System;
    
    
    /// <summary>
    ///   A strongly-typed resource class, for looking up localized strings, etc.
    /// </summary>
    // This class was auto-generated by the StronglyTypedResourceBuilder
    // class via a tool like ResGen or Visual Studio.
    // To add or remove a member, edit your .ResX file then rerun ResGen
    // with the /str option, or rebuild your VS project.
    [global::System.CodeDom.Compiler.GeneratedCodeAttribute("System.Resources.Tools.StronglyTypedResourceBuilder", "17.0.0.0")]
    [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
    [global::System.Runtime.CompilerServices.CompilerGeneratedAttribute()]
    internal class Resources {
        
        private static global::System.Resources.ResourceManager resourceMan;
        
        private static global::System.Globalization.CultureInfo resourceCulture;
        
        [global::System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1811:AvoidUncalledPrivateCode")]
        internal Resources() {
        }
        
        /// <summary>
        ///   Returns the cached ResourceManager instance used by this class.
        /// </summary>
        [global::System.ComponentModel.EditorBrowsableAttribute(global::System.ComponentModel.EditorBrowsableState.Advanced)]
        internal static global::System.Resources.ResourceManager ResourceManager {
            get {
                if (object.ReferenceEquals(resourceMan, null)) {
                    global::System.Resources.ResourceManager temp = new global::System.Resources.ResourceManager("TradeControl.Node.Properties.Resources", typeof(Resources).Assembly);
                    resourceMan = temp;
                }
                return resourceMan;
            }
        }
        
        /// <summary>
        ///   Overrides the current thread's CurrentUICulture property for all
        ///   resource lookups using this strongly typed resource class.
        /// </summary>
        [global::System.ComponentModel.EditorBrowsableAttribute(global::System.ComponentModel.EditorBrowsableState.Advanced)]
        internal static global::System.Globalization.CultureInfo Culture {
            get {
                return resourceCulture;
            }
            set {
                resourceCulture = value;
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Error log write failure. Check file permissions on {0}..
        /// </summary>
        internal static string ErrorLogFailure {
            get {
                return ResourceManager.GetString("ErrorLogFailure", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Timestamp, Message, Source, Target, Inner Message.
        /// </summary>
        internal static string ErrorLogHeader {
            get {
                return ResourceManager.GetString("ErrorLogHeader", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to /**************************************************************************************
        ///Trade Control
        ///Node Creation Script - SCHEMA + LOGIC + CONTROL DATA
        ///Release: 3.23.1
        ///
        ///Date: 1 August 2019
        ///Author: Ian Monnox
        ///
        ///Trade Control by Trade Control Ltd is licensed under GNU General Public License v3.0. 
        ///
        ///You may obtain a copy of the License at
        ///
        ///	https://www.gnu.org/licenses/gpl-3.0.en.html
        ///
        ///***********************************************************************************/
        ///go
        ///CREATE SCHEMA Activi [rest of string was truncated]&quot;;.
        /// </summary>
        internal static string tc_create_node {
            get {
                return ResourceManager.GetString("tc_create_node", resourceCulture);
            }
        }
    }
}
